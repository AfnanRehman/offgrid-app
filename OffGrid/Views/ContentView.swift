//
//  ContentView.swift
//  OffGrid
//
//  Created by Afnan Rehman on 8/27/24.
//

import SwiftUI

struct ContentView: View {
    @State private var messageToSend = ""
    @State private var receivedMessages = [String]()
    @State private var connectionStatus = "Searching for peers..."
    
    private var multipeerSession = MultipeerSession()
    
    var body: some View {
        VStack {
            Text(connectionStatus)
                .padding()
                .foregroundColor(.green)
                .font(.headline)
            
            List(receivedMessages, id: \.self) { message in
                Text(message)
            }
            
            HStack {
                TextField("Enter message", text: $messageToSend)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    multipeerSession.send(message: messageToSend)
                    receivedMessages.append("You: \(messageToSend)")
                    messageToSend = ""
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }.padding()
        }
        .onAppear {
            // Set connection status handler
            multipeerSession.connectionStatusHandler = { status in
                connectionStatus = status
            }
            
            // Set received message handler
            multipeerSession.receivedMessageHandler = { message in
                receivedMessages.append("Peer: \(message)")
            }
        }
    }
}


#Preview {
    ContentView()
}
