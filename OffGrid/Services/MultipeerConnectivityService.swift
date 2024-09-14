//
//  MultipeerConnectivityService.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//


import Foundation
import MultipeerConnectivity

protocol MultipeerConnectivityServiceDelegate: AnyObject {
    func didReceive(message: Message)
    func foundPeer(peerID: MCPeerID)
    func lostPeer(peerID: MCPeerID)
    func receivedInvitation(fromPeer peerID: MCPeerID)
    func authenticationNeeded(fromPeer peerID: MCPeerID)
}

class MultipeerConnectivityService: NSObject {
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let serviceType = "offgridchat"

    private(set) var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser

    weak var delegate: MultipeerConnectivityServiceDelegate?

    var foundPeers: [MCPeerID] = []
    var invitations: [MCPeerID: (Bool, MCSession?) -> Void] = [:]
    var pendingCertificates: [MCPeerID: (Bool) -> Void] = [:]

    override init() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }

    func send(message: Message) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending message: \(error)")
        }
    }

    func invitePeer(_ peerID: MCPeerID) {
        guard !session.connectedPeers.contains(peerID) else { return }
        let context = "your-secret-code".data(using: .utf8)
        browser.invitePeer(peerID, to: session, withContext: context, timeout: 10)
    }
}

// MARK: - MCSessionDelegate
extension MultipeerConnectivityService: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected to peer: \(peerID.displayName)")
        case .connecting:
            print("Connecting to peer: \(peerID.displayName)")
        case .notConnected:
            print("Disconnected from peer: \(peerID.displayName)")
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(Message.self, from: data) {
            delegate?.didReceive(message: message)
        }
    }

    // Required but unused methods
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?,
                 fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.pendingCertificates[peerID] = certificateHandler
            self.delegate?.authenticationNeeded(fromPeer: peerID)
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerConnectivityService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        DispatchQueue.main.async {
            self.invitations[peerID] = invitationHandler
            self.delegate?.receivedInvitation(fromPeer: peerID)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertiser did not start advertising: \(error.localizedDescription)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerConnectivityService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.foundPeers.append(peerID)
            self.delegate?.foundPeer(peerID: peerID)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            if let index = self.foundPeers.firstIndex(of: peerID) {
                self.foundPeers.remove(at: index)
                self.delegate?.lostPeer(peerID: peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browser did not start browsing for peers: \(error.localizedDescription)")
    }
}
