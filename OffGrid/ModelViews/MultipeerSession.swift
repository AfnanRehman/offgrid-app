//
//  MultipeerSession.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/3/24.
//

import Foundation
import MultipeerConnectivity

import MultipeerConnectivity

class MultipeerSession: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    var peerID: MCPeerID!
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    // Handler for connection status updates
    var connectionStatusHandler: ((String) -> Void)?
    
    var receivedMessageHandler: ((String) -> Void)?
    
    override init() {
        super.init()
        
        // Initialize peerID and session
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        let serviceType = "airplanechat"  // Compliant service type string
        
        // Start advertising and browsing for nearby peers
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()

        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()

    }
    
    func send(message: String) {
        guard !session.connectedPeers.isEmpty else { return }
        
        if let data = message.data(using: .utf8) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
    
    // MARK: - MCSessionDelegate Methods
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\(peerID.displayName) connected")
            DispatchQueue.main.async {
                self.connectionStatusHandler?("\(peerID.displayName) connected.")
            }
        case .notConnected:
            print("\(peerID.displayName) disconnected")
            DispatchQueue.main.async {
                self.connectionStatusHandler?("\(peerID.displayName) disconnected.")
            }
        case .connecting:
            print("Connecting to \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionStatusHandler?("Connecting to \(peerID.displayName)...")
            }
        @unknown default:
            print("Unknown state for peer: \(peerID.displayName)")
        }
    }


    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            print("Received message: \(message)")
            DispatchQueue.main.async {
                self.receivedMessageHandler?(message)
            }
        }
    }

    
    // Handle other required MCSessionDelegate methods (empty for now)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    // MARK: - MCNearbyServiceAdvertiserDelegate Methods
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)  // Automatically accept invitations
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate Methods
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }

}
