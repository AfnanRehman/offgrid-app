//
//  MessageRow.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import SwiftUI

struct MessageRow: View {
    let message: Message

    var isCurrentUser: Bool {
        message.sender == UIDevice.current.name
    }

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                Text(message.content)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Text(message.content)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(8)
                Spacer()
            }
        }
        .padding([.leading, .trailing], 10)
    }
}
