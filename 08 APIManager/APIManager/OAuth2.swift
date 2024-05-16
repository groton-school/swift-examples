//
//  OAuth2.swift
//  OAuth2Authorization
//
//  Created by Seth Battis on 3/21/24.
//

import Foundation
import CommonCrypto

class OAuth2 {
    let authURL: URL
    let tokenURL: URL
    let clientID: String
    let clientSecret: String?
    let flow: OAuth2.AuthorizationFlow
    let authorizeInHeader: Bool
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
    ///   - flow: desired authorization flow (using client secret or PKCE)
    ///   - authorizeInHeader: whether or not to pass the client ID and secret as form fields or Basic Authorization header
    init(authURL: URL, tokenURL: URL, clientID: String, clientSecret: String? = nil, scope: String? = nil, redirectURI: URL, flow: OAuth2.AuthorizationFlow = .PKCE, authorizeInHeader: Bool = false) {
        self.authURL = authURL
        self.tokenURL = tokenURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scope = scope
        self.redirectURI = redirectURI
        self.flow = flow
        self.authorizeInHeader = authorizeInHeader
    }
    
    func getAuthorizationURL() -> URL {
        var queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "state", value: createState())
        ]
        
        if flow == .PKCE {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "code_challenge", value: createCodeChallenge()),
                URLQueryItem(name: "code_challenge_method", value: "S256"),
            ])
        }
        
        if (scope != nil) {
            queryItems.append(URLQueryItem(name: "scope", value: scope))
        }
        return authURL.appending(queryItems: queryItems)
    }
    
    /// - parameters
    ///   - redirectedURL: The URL passed intp the app via URL scheme
    ///   - completionHandler: Closure that will receive the resulting `TokenResponse` (or error)
    func handleRedirect(_ redirectedURL: URL, completionHandler: @escaping (TokenResponse?, Error?) -> Void) -> Void {
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
        
        requestToken(
            grantType: .AuthorizationCode,
            code: components!.queryItems!.first(where: {$0.name == "code"})!.value!,
            completionHandler: completionHandler
        )
    }
    
    public func requestToken(grantType: GrantType, code: String? = nil, refreshToken: String? = nil, completionHandler: @escaping (TokenResponse?, Error?) -> Void) {
        var body: [URLQueryItem] = []
        var tokenRequest = URLRequest(url: tokenURL)

        switch grantType {
        case .AuthorizationCode:
            guard code != nil else {
                completionHandler(nil, OAuth2Error.InvalidAuthorizationCode)
                return
            }
            body.append(URLQueryItem(name: "code", value: code))
            body.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
            body.append(URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString))
            
            if flow == .PKCE {
                body.append(URLQueryItem(name: "client_id", value: clientID))
                body.append(URLQueryItem(name: "code_verifier", value: verifier))
            }
            break
        case .RefreshToken:
            guard refreshToken != nil else {
                completionHandler(nil, OAuth2Error.InvalidRefreshToken)
                return
            }
            body.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
            body.append(URLQueryItem(name: "refresh_token", value: refreshToken))
            break
        }
        
        if flow == .ClientSecret{
            if authorizeInHeader {
                let authorization = "\(clientID):\(clientSecret ?? "")"
                tokenRequest.setValue("Basic \(authorization.data(using: .utf8)?.base64EncodedString() ?? "")", forHTTPHeaderField: "Authorization")
            } else {
                body.append(URLQueryItem(name: "client_id", value: clientID))
                body.append(URLQueryItem(name: "client_secret", value: clientSecret))
            }
        }
        
        var httpBody = URLComponents();
        httpBody.queryItems = body;
        
        tokenRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        tokenRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        tokenRequest.httpMethod = "POST"
        tokenRequest.httpBody = httpBody.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: tokenRequest) {data, response, error in
            guard data != nil else {
                completionHandler(nil, OAuth2Error.APIResponse(error: "no data returned"))
                return
            }
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data!)
                completionHandler(tokenResponse, nil)
            } catch {
                print(String(data: Data(base64Encoded: data!.base64EncodedString())!, encoding: .utf8)!)
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
    
    private func createState() -> String {
        state = randomString()
        return state!
    }
    
    private func createVerifier() -> String {
        verifier = randomString();
        return verifier!
    }
    
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce/add-login-using-the-authorization-code-flow-with-pkce#swift-5-sample
    private func randomString(length: Int = 43) -> String {
        var buffer = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    /// https://auth0.com/docs/get-started/authentication-and-authorization-flow/authorization-code-flow-with-pkce/add-login-using-the-authorization-code-flow-with-pkce#swift-5-sample
    private func createCodeChallenge() -> String? {
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
        case InvalidAuthorizationCode
        case InvalidRefreshToken
        case APIResponse(error: String)
    }
    
    enum AuthorizationFlow {
        case ClientSecret
        case PKCE
    }
    
    enum GrantType {
        case AuthorizationCode
        case RefreshToken
    }
    
    struct TokenResponse: Codable, Hashable  {
        let access_token: String
        let token_type: String
        let scope: String?
        let expires_in: Int?
        let refresh_token: String?
    }
}

