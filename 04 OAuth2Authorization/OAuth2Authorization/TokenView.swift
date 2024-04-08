//
//  TokenView.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct TokenView: View {
    let token: OAuth2.TokenResponse
    
    var body: some View {
        List {
            LabeledContent {
                // FIXME incorrectly hypenates the token
                Text(token.access_token)
            } label: {
                Text("access_token")
            }
            LabeledContent {
                Text(token.token_type)
            } label: {
                Text("token_type")
            }
            LabeledContent {
                Text(token.scope ?? "-")
            } label: {
                Text("scope")
            }
            LabeledContent {
                if token.expires_in != nil {
                    Text("\(String(token.expires_in!)) seconds")
                } else {
                    Text("-")
                }
            } label: {
                Text("expires_in")
            }
            LabeledContent {
                // FIXME incorrectly hypenates the token
                Text(token.refresh_token ?? "-")
            } label: {
                Text("refresh_token")
            }
        }.scrollContentBackground(.hidden)
   }
}

#Preview {
    TokenView(token: OAuth2.TokenResponse(
        access_token: "gho_BRE49VSxURTQ9HUzsYHGXsoFmxcfWZ3Qh9er",
        token_type: "bearer",
        scope: "",
        expires_in: nil,
        refresh_token: nil
    ))
}
