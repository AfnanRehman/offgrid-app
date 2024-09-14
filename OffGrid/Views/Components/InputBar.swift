//
//  InputBar.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import SwiftUI

struct InputBar: View {
    @Binding var messageText: String
    var sendAction: () -> Void

    var body: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minHeight: CGFloat(30))

            Button(action: {
                sendAction()
            }) {
                Text("Send")
                    .bold()
            }
            .padding(.leading, 5)
        }
        .padding()
    }
}
