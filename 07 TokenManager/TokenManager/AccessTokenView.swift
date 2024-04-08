//
//  TokenView.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct AccessTokenView: View {
    var accessToken: String?
    
    var body: some View {
        if accessToken != nil {
            Section(header: Text("Access Token (memory-only)")) {
                LabeledContent {
                    // FIXME incorrectly hypenates the token
                    Text(accessToken!).frame(maxHeight: 200)
                } label: {
                    Text("access_token")
                }
            }
        } else {
            Section {
                Text("No access token")
            }
        }
    }
}

#Preview {
    AccessTokenView(accessToken: "foo")
}
