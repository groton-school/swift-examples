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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RefreshToken.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(tokenManager)
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        let keys = Keys.OrgGrotonSwiftExamplesTokenManagerKeys()
        tokenManager = TokenManager(
            oauth2: OAuth2(
                authURL: URL(string: "https://app.blackbaud.com/oauth/authorize")!,
                tokenURL: URL(string: "https://oauth2.sky.blackbaud.com/token")!,
                clientID: keys.clientID,
                clientSecret: keys.clientSecret,
                redirectURI: URL(string: keys.redirectURI)!
            ),
            modelContext: sharedModelContainer.mainContext
        )
    }
}
