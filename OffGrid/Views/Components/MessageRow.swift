//
//  MessageBar.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import Foundation
// MessageRow.swift
import SwiftUI

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            if message.sender == UIDevice.current.name {
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
