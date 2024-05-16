//
//  APIManager.swift
//  APIManager
//
//  Created by Seth Battis on 4/8/24.
//

import Foundation

class APIManager: TokenManager {
    private let baseURL: URL
    private let headers: [(String, String)]

    
    init(authURL: URL, tokenURL: URL, clientID: String, clientSecret: String? = nil, scope: String? = nil, redirectURI: URL, keychainTag: String? = nil, baseURL: URL, headers: [(String, String)] = [], flow: OAuth2.AuthorizationFlow = .PKCE, authorizeInHeader: Bool = false) {
        self.baseURL = baseURL
        self.headers = headers
        super.init(authURL: authURL, tokenURL: tokenURL, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI, flow: flow, authorizeInHeader: authorizeInHeader)
    }
    
    
    func request<ExpectedResponseType: Codable>(endpoint: String, method: RequestMethod = .get, body: Codable? = nil, completionHandler: @escaping (ExpectedResponseType?, Error?) -> Void) throws {
        var request = try prepareRequest(endpoint: endpoint, method: method, body: body)
        getToken() {accessToken in
            guard accessToken != nil else {
                completionHandler(nil, APIError.Unauthorized)
                return
            }
            request.setValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) {data, response, error in
                guard data != nil else {
                    completionHandler(nil, APIError.APIResponse(error: "no data returned"))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(ExpectedResponseType.self, from: data!)
                    completionHandler(response, nil)
                } catch {
                    completionHandler(nil, APIError.Encoding(error: error))
                }
            }.resume()
        }
    }

    private func prepareRequest(endpoint: String, method: RequestMethod = .get, body: Codable? = nil) throws -> URLRequest {
        var request = URLRequest(url: URL(string: endpoint, relativeTo: baseURL)!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
        request.httpMethod = method.rawValue
        if body != nil {
            do {
                request.httpBody = try JSONEncoder().encode(body!)
            } catch {
                throw APIError.Encoding(error: error)
            }
        }
        return request
    }

    enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    enum APIError: Error {
        case Encoding(error: Error)
        case APIResponse(error: String)
        case Unauthorized
    }
}
