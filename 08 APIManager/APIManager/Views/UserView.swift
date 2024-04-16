//
//  UserView.swift
//  APIManager
//
//  Created by Seth Battis on 4/8/24.
//

import SwiftUI

struct UserView: View {
    @Environment(APIManager.self) var apiManager: APIManager
    let userId: Int32?
    @State var user: User?
    @State var error: Error?
    
    var body: some View {
        if user == nil {
            if error == nil {
                ProgressView("Loading…").task {
                    do {
                        try apiManager.request(endpoint: "users/\(userId != nil ? String(userId!) : "me")") {user, error in
                            self.user = user
                            self.error = error
                        }
                    } catch {
                        self.error = error
                    }
                }
            } else {
                ErrorView(error!)
            }
        } else {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "person.fill")
                    Text("\(preferredName()) \(user!.last_name ?? "")")
                }
                Text(user!.email ?? "")
                Spacer()
                Button(action: apiManager.deauthorize, label: {Text("Sign Out")})
            }
        }
    }
    
    func preferredName() -> String {
        if user != nil {
            if user!.preferred_name != nil && !user!.preferred_name!.isEmpty {
                return user!.preferred_name!
            }
            if user!.nick_name != nil && !user!.nick_name!.isEmpty {
                return user!.nick_name!
            }
            if user!.first_name != nil {
                return user!.first_name!
            }
        }
        return ""
    }
    
    init(userId: Int32? = nil) {
        self.userId = userId
    }
    
    init(_ user: User) {
        self.userId = nil
        self.user = user
    }
}

#Preview {
    UserView(userId: 4641975).environment(APIManagerApp().apiManager)
}
