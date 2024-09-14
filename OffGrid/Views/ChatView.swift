//
//  ChatView.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import SwiftUI
import MultipeerConnectivity

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var showingPeerSelection = false
    @State private var showingInvitation = false
    @State private var currentInvitationPeer: MCPeerID?
    @State private var showingAuthentication = false
    @State private var currentAuthPeer: MCPeerID?

    var body: some View {
        VStack {
            List(viewModel.messages) { message in
                MessageRow(message: message)
            }
            InputBar(messageText: $viewModel.currentMessage, sendAction: viewModel.sendMessage)
        }
        .navigationBarTitle("Chat")
        .navigationBarItems(trailing: Button("Connect") {
            showingPeerSelection = true
        })
        .onAppear {
            viewModel.startSession()
        }
        .onReceive(viewModel.$invitations) { invitations in
            if let peerID = invitations.first {
                currentInvitationPeer = peerID
                showingInvitation = true
            }
        }
        .onReceive(viewModel.$peersNeedingAuthentication) { peers in
            if let peerID = peers.first {
                currentAuthPeer = peerID
                showingAuthentication = true
            }
        }
        .sheet(isPresented: $showingPeerSelection) {
            PeerSelectionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingInvitation) {
            if let peerID = currentInvitationPeer {
                InvitationView(viewModel: viewModel, isPresented: $showingInvitation, peerID: peerID)
            }
        }
        .sheet(isPresented: $showingAuthentication) {
            if let peerID = currentAuthPeer {
                AuthenticationView(viewModel: viewModel, isPresented: $showingAuthentication, peerID: peerID)
            }
        }
    }
}
