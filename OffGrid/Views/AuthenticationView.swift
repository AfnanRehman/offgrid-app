//
//  AuthenticationView.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import SwiftUI
import MultipeerConnectivity

struct AuthenticationView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var isPresented: Bool
    var peerID: MCPeerID

    var body: some View {
        VStack(spacing: 20) {
            Text("Authenticate \(peerID.displayName)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            Text("Confirm that you trust this device.")
                .multilineTextAlignment(.center)
                .padding()
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.respondToAuthentication(from: peerID, accept: false)
                    isPresented = false
                }) {
                    Text("Decline")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                Button(action: {
                    viewModel.respondToAuthentication(from: peerID, accept: true)
                    isPresented = false
                }) {
                    Text("Accept")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}
