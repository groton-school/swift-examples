//
//  ContentView.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TokenManager.self) var tokenManager: TokenManager
    @Query private var refreshTokens: [RefreshToken]

    var body: some View {
        if tokenManager.authorized {
            Form {
                TokenView(token: tokenManager.currentToken)
                
                ForEach(refreshTokens) {token in
                    RefreshTokenView(refreshToken: token)
                    
                }
                
                Section {
                    Button(action: tokenManager.deauthorize, label: {
                        Text("Deauthorize")
                    })
                }
            }
        } else {
            tokenManager.authorizationView(flow: .ClientSecret)
                .onOpenURL() { url in
                    tokenManager.handleRedirect(url: url, flow: .ClientSecret)
                }
        }
    }
}

#Preview {
    ContentView().environment(TokenManagerApp().tokenManager)
}
