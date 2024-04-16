//
//  ContentView.swift
//  TokenManager
//
//  Created by Seth Battis on 4/6/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(APIManager.self) var apiManager: APIManager
    @State var user: User?
    @State var error: Error?

    var body: some View {
        if apiManager.authorized {
            if user == nil {
                if error == nil {
                    ProgressView()
                        .task {
                            do {
                                try apiManager.request(endpoint: "users/me") {user, error in
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
                NavigationStack {
                    List {
                        NavigationLink ("UserView (no arguments, self-loads 'me')") {
                            UserView()
                        }
                        NavigationLink ("UserView (logged-in user as argument)") {
                            UserView(user!)
                        }
                        NavigationLink("UserView (ID of logged in user as argument") {
                            UserView(userId: user!.id)
                        }
                    }
                }
            }
        } else {
            apiManager.authorizationView(flow: .ClientSecret)
                .onOpenURL() { url in
                    apiManager.handleRedirect(url, flow: .ClientSecret)
                }
        }
    }
}

#Preview {
    ContentView().environment(APIManagerApp().apiManager)
}
