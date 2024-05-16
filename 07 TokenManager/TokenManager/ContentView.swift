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
    @State var flow: OAuth2.AuthorizationFlow? = nil
    
    var body: some View {
        if tokenManager.authorized {
            Form {
                AccessTokenView(accessToken: tokenManager.currentToken?.access_token)
                
                if tokenManager.refreshToken != nil {
                    RefreshTokenView(refreshToken: tokenManager.refreshToken!)
                }
                
                Section {
                    Button(action: {
                        flow = nil
                        tokenManager.deauthorize()
                    }, label: {
                        Text("Deauthorize")
                    })
                }
            }
        } else {
            if flow == nil {
                VStack {
                    Button("Client Secret") {
                        setFlow(.ClientSecret)
                    }
                    Button("PKCE") {
                        setFlow(.PKCE)
                    }
                }
            } else {
                tokenManager.authorizationView().onOpenURL() { url in
                    tokenManager.handleRedirect(url)
                }

            }
        }
    }
    
    func setFlow(_ flow: OAuth2.AuthorizationFlow) {
        tokenManager.flow = flow
        self.flow = tokenManager.flow
    }
}

#Preview {
    ContentView().environment(TokenManagerApp().tokenManager)
}
