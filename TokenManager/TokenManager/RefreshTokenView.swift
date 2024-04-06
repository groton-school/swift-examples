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
    var refreshToken: RefreshToken
    var body: some View {
        Section(header: Text("Refresh Token (persistent storage)")) {
            LabeledContent {
                Text(refreshToken.refreshToken)
            } label: {
                Text("refresh_token")
            }
            Button(
                action: tokenManager.refreshToken,
                label: {
                    Text("Exchange for Access Token")
                }
            )
        }
        
    }
}
    

#Preview {
    RefreshTokenView(refreshToken: RefreshToken(refreshToken: "foo"))
        .environment(TokenManagerApp().tokenManager)
}
