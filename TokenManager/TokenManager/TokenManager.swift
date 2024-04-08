//
//  TokenManager.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import Foundation

@Observable
class TokenManager: OAuth2 {
    var currentToken: OAuth2.TokenResponse?
    private(set) var authorized: Bool
    private let keychainTag: String
    var refreshToken: String?
    
    init(authURL: URL, tokenURL: URL, clientID: String, clientSecret: String? = nil, scope: String? = nil, redirectURI: URL, keychainTag: String? = nil) {
        self.keychainTag = keychainTag ?? tokenURL.absoluteString
        authorized = false
        currentToken = nil
        do {
            refreshToken = try Keychain.get(tag: self.keychainTag)
        } catch {
            print(error)
            refreshToken = nil
        }
        super.init(authURL: authURL, tokenURL: tokenURL, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
        setAuthorized()
    }
        
    private func setAuthorized() {
        authorized = currentToken != nil || refreshToken != nil
    }
    
    func deauthorize() {
        currentToken = nil
        refreshToken = nil
        do {
            try Keychain.delete(tag: keychainTag)
            setAuthorized()
        } catch {
            fatalError("Error deleting refresh tokens: \(error)")
        }
    }
    
    func authorizationView(flow: OAuth2.AuthorizationFlow = .PKCE) -> WebView {
        return WebView(url: getAuthorizationURL(flow: flow), clearData: !authorized)
    }
    
    func handleRedirect(_ redirectedURL: URL, flow: OAuth2.AuthorizationFlow = .PKCE) {
        super.handleRedirect(redirectedURL, flow: flow, completionHandler: storeToken)
    }
    
    func refresh() {
        requestToken(grantType: .RefreshToken, refreshToken: refreshToken, completionHandler: storeToken)
    }
    
    private func storeToken(tokenResponse: OAuth2.TokenResponse?, error: Error?) {
        guard error == nil else {
            print(error!.localizedDescription)
            return
        }
        guard tokenResponse != nil else {
            print("nil token response")
            return
        }
        self.currentToken = tokenResponse
        if tokenResponse?.refresh_token != nil {
            do {
                if refreshToken != nil {
                    try Keychain.update(currentToken!.refresh_token!, tag: keychainTag)
                } else {
                    try Keychain.save(currentToken!.refresh_token!, tag: keychainTag)
                }
                refreshToken = currentToken!.refresh_token
            } catch {
                fatalError("Error storing token: \(error)")
            }
        }
        setAuthorized()
    }
}
