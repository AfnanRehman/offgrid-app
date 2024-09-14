//
//  PeerSelectionView.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import SwiftUI
import MultipeerConnectivity

struct PeerSelectionView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        NavigationView {
            List(viewModel.availablePeers, id: \.self) { peerID in
                Button(action: {
                    viewModel.invitePeer(peerID)
                }) {
                    Text(peerID.displayName)
                }
            }
            .navigationBarTitle("Select a Peer", displayMode: .inline)
        }
    }
}
