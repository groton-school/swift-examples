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
    
    init(authURL: URL, tokenURL: URL, clientID: String, clientSecret: String? = nil, scope: String? = nil, redirectURI: URL, keychainTag: String? = nil, flow: OAuth2.AuthorizationFlow = .PKCE, authorizeInHeader: Bool = false) {
        let _keychainTag = keychainTag ?? tokenURL.absoluteString
        self.keychainTag = _keychainTag
        authorized = false
        currentToken = nil
        super.init(authURL: authURL, tokenURL: tokenURL, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI, flow: flow, authorizeInHeader: authorizeInHeader)
        do {
            refreshToken = try Keychain.get(tag: _keychainTag)
        } catch {
            print("Error loading \(_keychainTag) from keychain: \(error)")
            refreshToken = nil
        }
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
        } catch {
            print("Error deleting \(keychainTag) from keychain: \(error)")
        }
        setAuthorized()
    }
    
    func authorizationView() -> WebView {
        return WebView(url: getAuthorizationURL(), clearData: !authorized)
    }
    
    func handleRedirect(_ redirectedURL: URL) {
        super.handleRedirect(redirectedURL,completionHandler: storeToken)
    }
    
    func refresh(completionHandler: @escaping (String?) -> Void) {
        requestToken(grantType: .RefreshToken, refreshToken: refreshToken) {tokenResponse, error in
            self.storeToken(tokenResponse: tokenResponse, error: error)
            completionHandler(self.currentToken?.access_token)
        }
    }
    
    func getToken(completionHandler: @escaping (String?) -> Void) {
        if authorized {
            if currentToken != nil {
                completionHandler(currentToken!.access_token)
            } else {
                refresh(completionHandler: completionHandler)
            }
        } else {
            completionHandler(nil)
        }
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
