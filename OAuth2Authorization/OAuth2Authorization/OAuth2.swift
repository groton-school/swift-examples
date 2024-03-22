//
//  OAuth2.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/21/24.
//

import Foundation
import CommonCrypto

struct OAuth2 {
    let authURL: URL
    let tokenURL: URL
    let clientID: String
    let clientSecret: String?
    let scope: String?
    let redirectURI: URL
    var state: String?
    var verifier: String?
    
    /// - parameters
    ///   - authUrl: URL for interactive authorization requests
    ///   - tokenURL: URL for requesting tokens (and refresh tokens)
    ///   - clientID: Generated Client ID value registered with the API
    ///   - clientSecret: (Optional) Client secret value registered with the API (not needed for recommended iOS PKCE authorization flow)
    ///   - scope: (Optional) Space-separated list of scopes to be requested with any token
    ///   - redirectURI: Redirect URI registered with the API
    init(authURL: URL, tokenURL: URL, clientID: String, clientSecret: String? = nil, scope: String? = nil, redirectURI: URL) {
        self.authURL = authURL
        self.tokenURL = tokenURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scope = scope
        self.redirectURI = redirectURI
    }

    /// - parameters
    ///   - flow: (Optional) The authorization flow being attempted (defaults to `.PKCE`
    mutating func getAuthorizationURL(flow: AuthorizationFlow = .PKCE) -> URL {
        var queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "state", value: createState())
        ]

        switch flow {
        case .PKCE:
            queryItems.append(contentsOf: [
                URLQueryItem(name: "code_challenge", value: createCodeChallenge()),
                URLQueryItem(name: "code_challenge_method", value: "S256"),
            ])
            break
        case .ClientSecret:
            break
        }
        
        if (scope != nil) {
            queryItems.append(URLQueryItem(name: "scope", value: scope))
        }
        return authURL.appending(queryItems: queryItems)
    }
    
    /// - parameters
    ///   - redirectedURL: The URL passed intp the app via URL scheme
    ///   - flow: (Optional) The authorization flow being attempted (defaults to `.PKCE`
    ///   - completionHandler: Closure that will receive the resulting `TokenResponse` (or error)
    mutating func handleRedirect(_ redirectedURL: URL, flow: AuthorizationFlow = .PKCE, completionHandler: @escaping (TokenResponse?, Error?) -> Void) -> Void {
        // not just any URL matching our app URL scheme should be processed!
        guard matchRedirectURI(proposed: redirectedURL) else {
            completionHandler(nil, OAuth2Error.RedirectedURIMismatch)
            return
        }
        
        // the state query parameter must match what we sent (and then is discarded, having fulfilled its purpose)
        let components = URLComponents(string: redirectedURL.absoluteString)
        guard components!.queryItems?.first(where: {$0.name == "state"})?.value == state else {
            completionHandler(nil, OAuth2Error.StateMismatch)
            return
        }
        state = nil

        var body = [
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: components!.queryItems!.first(where: {$0.name == "code"})!.value!),
                URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
                URLQueryItem(name: "client_id", value: clientID),
            ]
        switch flow {
        case .PKCE:
            body.append(
                URLQueryItem(name: "code_verifier", value: verifier)
            )
            verifier = nil
            break;
        case .ClientSecret:
            
            body.append(
                URLQueryItem(name: "client_secret", value: clientSecret)
            )
            break;
        }
        var httpBody = URLComponents();
        httpBody.queryItems = body;
        
        var tokenRequest = URLRequest(url: tokenURL)
        tokenRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        tokenRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        tokenRequest.httpMethod = "POST"
        tokenRequest.httpBody = httpBody.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: tokenRequest) {data, response, error in
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data!)
                completionHandler(tokenResponse, nil)
            } catch {
                completionHandler(nil, OAuth2Error.APIResponse(error: String(data: Data(base64Encoded: data!.base64EncodedString())!, encoding: .utf8)!))
            }
        }.resume()
    }
    
    private func matchRedirectURI(proposed: URL) -> Bool {
        let proposedComponents = URLComponents(url: proposed, resolvingAgainstBaseURL: true)
        let expectedComponents = URLComponents(url: redirectURI, resolvingAgainstBaseURL: true)
        
        return proposedComponents?.scheme?.lowercased() == expectedComponents?.scheme?.lowercased() &&
        proposedComponents?.host?.lowercased() == expectedComponents?.host?.lowercased() &&
        proposedComponents?.user == expectedComponents?.user &&
        proposedComponents?.password == expectedComponents?.password &&
        proposedComponents?.path == expectedComponents?.path
    }
    
    private mutating func createState() -> String {
        state = randomString()
        return state!
    }
    
    private mutating func createVerifier() -> String {
        verifier = randomString();
        return verifier!
    }
    
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce/add-login-using-the-authorization-code-flow-with-pkce#swift-5-sample
    private mutating func randomString(length: Int = 43) -> String {
        var buffer = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce/add-login-using-the-authorization-code-flow-with-pkce#swift-5-sample
    private mutating func createCodeChallenge() -> String? {
        guard let data = createVerifier().data(using: .utf8) else { return nil }
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
        }
        let hash = Data(buffer)
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return challenge

    }
    
    enum OAuth2Error: Error {
        case RedirectedURIMismatch
        case StateMismatch
        case APIResponse(error: String)
    }
    
    enum AuthorizationFlow {
        case ClientSecret
        case PKCE
    }
        
    struct TokenResponse: Codable, Hashable  {
        let access_token: String
        let token_type: String
        let scope: String?
        let expires_in: Int?
        let refresh_token: String?
    }
}

