//
//  RefreshToken.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import Foundation
import SwiftData

@Model
class RefreshToken {
    var timestamp: Date
    var refreshToken: String
    
    init(refreshToken: String, timestamp: Date = .now) {
        self.timestamp = timestamp
        self.refreshToken = refreshToken
    }
}
