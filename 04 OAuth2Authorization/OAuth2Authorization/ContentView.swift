//
//  ContentView.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/21/24.
//

import SwiftUI
import Keys

struct ContentView: View {
    
    @State private var path = NavigationPath()
    @State private var token: OAuth2.TokenResponse?
    
    var body: some View {
        let keys = Keys.OrgGrotonSwiftExamplesOAuth2AuthorizationKeys()
        let oauth2 = OAuth2(
            authURL: URL(string: "https://github.com/login/oauth/authorize")!,
            tokenURL: URL(string: "https://github.com/login/oauth/access_token")!,
            clientID: keys.clientID,
            clientSecret: keys.clientSecret,
            redirectURI: URL(string: keys.redirectURI)!,
            flow: .ClientSecret
        )
        
        if (token == nil) {
            NavigationStack(path: $path) {
                VStack {
                    NavigationLink(
                        destination: WebView(url: oauth2.getAuthorizationURL(), clearData: true),
                        label: {
                            HStack {
                                Image(systemName: "person.badge.key.fill")
                                Text("Get GitHub API Access Token")
                            }
                        }
                    )
                }.onOpenURL(perform: {url in
                    oauth2.handleRedirect(url, completionHandler: storeToken)
                })
            }
        } else {
            VStack {
                TokenView(token: token!)
                Button("Refresh Token", action: {
                    oauth2.requestToken(grantType: .RefreshToken, refreshToken: token?.refresh_token, completionHandler: storeToken)
                })
            }
        }
    }
    
    private func storeToken(_ token: OAuth2.TokenResponse?, _ error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        guard token != nil else {
            print("nil token")
            return;
        }
        self.token = token

    }
}

#Preview {
    ContentView()
}
