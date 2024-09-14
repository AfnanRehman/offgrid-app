//
//  Message.swift
//  OffGrid
//
//  Created by Afnan Rehman on 9/13/24.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let sender: String
    let content: String
    let timestamp: Date
}
