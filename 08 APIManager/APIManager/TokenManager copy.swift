//
//  TokenManager.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import Foundation
import SwiftData

@Observable
class TokenManager {
    private var modelContext: ModelContext
    private var oauth2: OAuth2
    var currentToken: OAuth2.TokenResponse?
    var refreshTokens: [RefreshToken]
    private(set) var authorized: Bool
    
    init(oauth2: OAuth2, currentToken: OAuth2.TokenResponse? = nil, modelContext: ModelContext) {
        self.modelContext = modelContext
        self.oauth2 = oauth2
        self.currentToken = currentToken
        do {
            refreshTokens = try modelContext.fetch(FetchDescriptor<RefreshToken>())
        } catch {
            fatalError(error.localizedDescription)
        }
        authorized = false
        setAuthorized()
    }
        
    private func setAuthorized() {
        authorized = currentToken != nil || refreshTokens.count > 0
    }
    
    func deauthorize() {
        currentToken = nil
        do {
            try modelContext.delete(model: RefreshToken.self)
            refreshTokens = try modelContext.fetch(FetchDescriptor<RefreshToken>())
            setAuthorized()
        } catch {
            fatalError("Error deleting refresh tokens: \(error)")
        }
    }
    
    func authorizationView(flow: OAuth2.AuthorizationFlow = .PKCE) -> WebView {
        return WebView(url: oauth2.getAuthorizationURL(flow: flow), clearData: !authorized)
    }
    
    func handleRedirect(url: URL, flow: OAuth2.AuthorizationFlow = .PKCE) {
        oauth2.handleRedirect(url, flow: flow, completionHandler: storeToken)
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
        if self.currentToken?.refresh_token != nil {
            do {
                modelContext.insert(RefreshToken(refreshToken: self.currentToken!.refresh_token!))
                self.refreshTokens = try modelContext.fetch(FetchDescriptor<RefreshToken>())
            } catch {
                fatalError("Error storing token: \(error)")
            }
        }
        setAuthorized()
    }
    
    func getToken(completionHandler: @escaping (String?) -> Void) throws {
        if authorized {
            if currentToken != nil {
                completionHandler(currentToken!.access_token)
            } else {
                refreshToken() {
                    completionHandler(self.currentToken?.access_token)
                }
            }
        } else {
            throw TokenManagerError.Unauthorized
        }
    }
    
    func refreshToken(completionHandler: @escaping () -> Void) {
        let refreshToken = refreshTokens.removeFirst()
        modelContext.delete(refreshToken)
        oauth2.requestToken(
            grantType: .RefreshToken,
            refreshToken: refreshToken.refreshToken
        ) {tokenResponse, error in
            self.storeToken(tokenResponse: tokenResponse, error: error)
            completionHandler()
        }
    }
    
    enum TokenManagerError: Error {
        case Unauthorized
    }
}
