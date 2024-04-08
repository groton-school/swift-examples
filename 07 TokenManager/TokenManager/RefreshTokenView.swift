//
//  RefreshTokenView.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import SwiftUI
import SwiftData

struct RefreshTokenView: View {
    @Environment(TokenManager.self) var tokenManager: TokenManager
    var refreshToken: String
    
    var body: some View {
        Section(header: Text("Refresh Token (device keychain)")) {
            LabeledContent {
                Text(refreshToken)
            } label: {
                Text("refresh_token")
            }
            Button(
                action: {
                    tokenManager.refresh(completionHandler: {_ in})
                },
                label: {
                    Text("Exchange for Access Token")
                }
            )
        }
        
    }
}
    

#Preview {
    RefreshTokenView(refreshToken: "foo")
        .environment(TokenManagerApp().tokenManager)
}
