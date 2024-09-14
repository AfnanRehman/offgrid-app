//
//  ChatViewModel.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import Foundation
import MultipeerConnectivity

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentMessage: String = ""
    @Published var availablePeers: [MCPeerID] = []
    @Published var invitations: [MCPeerID] = []
    @Published var peersNeedingAuthentication: [MCPeerID] = []

    private var multipeerService: MultipeerConnectivityService

    init() {
        self.multipeerService = MultipeerConnectivityService()
        self.multipeerService.delegate = self
    }

    func startSession() {
        multipeerService.start()
    }

    func sendMessage() {
        let message = Message(
            id: UUID(),
            sender: multipeerService.myPeerID.displayName,
            content: currentMessage,
            timestamp: Date()
        )
        messages.append(message)
        multipeerService.send(message: message)
        currentMessage = ""
    }

    func invitePeer(_ peerID: MCPeerID) {
        multipeerService.invitePeer(peerID)
    }

    func respondToInvitation(from peerID: MCPeerID, accept: Bool) {
        if let invitationHandler = multipeerService.invitations[peerID] {
            invitationHandler(accept, accept ? multipeerService.session : nil)
            multipeerService.invitations.removeValue(forKey: peerID)
        }
        if let index = invitations.firstIndex(of: peerID) {
            invitations.remove(at: index)
        }
    }

    func respondToAuthentication(from peerID: MCPeerID, accept: Bool) {
        if let certificateHandler = multipeerService.pendingCertificates[peerID] {
            certificateHandler(accept)
            multipeerService.pendingCertificates.removeValue(forKey: peerID)
        }
        if let index = peersNeedingAuthentication.firstIndex(of: peerID) {
            peersNeedingAuthentication.remove(at: index)
        }
    }
}

extension ChatViewModel: MultipeerConnectivityServiceDelegate {
    func didReceive(message: Message) {
        DispatchQueue.main.async {
            self.messages.append(message)
        }
    }

    func foundPeer(peerID: MCPeerID) {
        if !availablePeers.contains(peerID) {
            availablePeers.append(peerID)
        }
    }

    func lostPeer(peerID: MCPeerID) {
        if let index = availablePeers.firstIndex(of: peerID) {
            availablePeers.remove(at: index)
        }
    }

    func receivedInvitation(fromPeer peerID: MCPeerID) {
        if !invitations.contains(peerID) {
            invitations.append(peerID)
        }
    }

    func authenticationNeeded(fromPeer peerID: MCPeerID) {
        if !peersNeedingAuthentication.contains(peerID) {
            peersNeedingAuthentication.append(peerID)
        }
    }
}
