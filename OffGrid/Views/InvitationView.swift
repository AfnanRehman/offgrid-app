//
//  InvitationView.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import SwiftUI
import MultipeerConnectivity

struct InvitationView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var isPresented: Bool
    var peerID: MCPeerID

    var body: some View {
        VStack(spacing: 20) {
            Text("\(peerID.displayName) wants to connect")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.respondToInvitation(from: peerID, accept: false)
                    isPresented = false
                }) {
                    Text("Decline")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                Button(action: {
                    viewModel.respondToInvitation(from: peerID, accept: true)
                    isPresented = false
                }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}
