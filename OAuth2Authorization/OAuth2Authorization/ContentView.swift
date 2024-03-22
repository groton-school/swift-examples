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
        var oauth2 = OAuth2(
            authURL: "https://github.com/login/oauth/authorize",
            tokenURL: "https://github.com/login/oauth/access_token",
            clientID: keys.clientID,
            clientSecret: keys.clientSecret,
            redirectURI: keys.redirectURI
        )
        
        if (token == nil) {
            NavigationStack(path: $path) {
                VStack {
                    NavigationLink(
                        destination: WebView(url: oauth2.getAuthorizationURL(flow: .ClientSecret), clearData: true),
                        label: {
                            HStack {
                                Image(systemName: "person.badge.key.fill")
                                Text("Get GitHub API Access Token")
                            }
                        }
                    )
                }.onOpenURL(perform: {url in
                    oauth2.handleRedirect(url, flow: .ClientSecret) {token, error in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        self.token = token
                    }
                })
            }
        } else {
            TokenView(token: token!)
        }
    }
}

#Preview {
    ContentView()
}