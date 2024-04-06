//
//  TokenView.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct TokenView: View {
    var token: OAuth2.TokenResponse?
    
    var body: some View {
        if token != nil {
            Section(header: Text("Access Token (memory-only)")) {
                LabeledContent {
                    // FIXME incorrectly hypenates the token
                    Text(token?.access_token ?? "")
                        .frame(maxHeight: 100)
                } label: {
                    Text("access_token")
                }
                LabeledContent {
                    Text(token?.token_type ?? "")
                } label: {
                    Text("token_type")
                }
                LabeledContent {
                    Text(token?.scope ?? "")
                } label: {
                    Text("scope")
                }
                LabeledContent {
                    if token?.expires_in != nil {
                        Text("\(String(token!.expires_in!)) seconds")
                    }
                } label: {
                    Text("expires_in")
                }
                LabeledContent {
                    // FIXME incorrectly hypenates the token
                    Text(token?.refresh_token ?? "")
                } label: {
                    Text("refresh_token")
                }
            }
        } else {
            Section {
                Text("No access token")
            }
        }
    }
}

struct TokenView_Previews: PreviewProvider, View {
    @State var token: OAuth2.TokenResponse? =
    OAuth2.TokenResponse(access_token: "<access_token>", token_type: "bearer", scope: nil, expires_in: 3600, refresh_token: nil)

    static var previews: some View {
        Self()
    }

    var body: some View {
        TokenView(token: token)
    }
}
