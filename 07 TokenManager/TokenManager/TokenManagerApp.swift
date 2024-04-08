//
//  TokenManagerApp.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import SwiftUI
import SwiftData
import Keys

@main
struct TokenManagerApp: App {
    @State var tokenManager: TokenManager
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(tokenManager)
        }
    }
    
    init() {
        let keys = Keys.OrgGrotonSwiftExamplesTokenManagerKeys()
        tokenManager = TokenManager(
            authURL: URL(string: "https://app.blackbaud.com/oauth/authorize")!,
            tokenURL: URL(string: "https://oauth2.sky.blackbaud.com/token")!,
            clientID: keys.clientID,
            clientSecret: keys.clientSecret,
            redirectURI: URL(string: keys.redirectURI)!
        )
    }
}
