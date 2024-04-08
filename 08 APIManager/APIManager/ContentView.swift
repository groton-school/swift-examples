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

    var body: some View {
        if apiManager.authorized {
            UserView()
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
