//
//  UserView.swift
//  APIManager
//
//  Created by Seth Battis on 4/8/24.
//

import SwiftUI

struct UserView: View {
    @Environment(APIManager.self) var apiManager: APIManager
    let userId: Int?
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
                Text(String(describing: error))
            }
        } else {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "person.fill")
                    Text("\(user!.preferred_name ?? user!.preferred_name ?? user!.first_name ?? "") \(user!.last_name ?? "")")
                }
                Text(user!.email ?? "")
                Spacer()
                Button(action: apiManager.deauthorize, label: {Text("Sign Out")})
            }
        }
    }
    
    init(userId: Int? = nil) {
        self.userId = userId
    }
}

#Preview {
    UserView(userId: 4641975).environment(APIManagerApp().apiManager)
}
