//
//  ContentView.swift
//  URLScheme
//
//  Created by Seth Battis on 3/21/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var urlLabel = "None"
    @State private var currentURL: URL?
    
    var body: some View {
        VStack {
            Form{
                LabeledContent {
                    Text(urlLabel)
                } label: {
                    Text("URL")
                }
                if currentURL != nil {
                    LabeledContent {
                        Text(currentURL!.scheme ?? "-")
                    } label: {
                        Text("Scheme")
                    }
                    LabeledContent {
                        Text(currentURL!.host() ?? "-")
                    } label: {
                        Text("Host")
                    }
                    LabeledContent {
                        Text(currentURL!.path())
                    } label: {
                        Text("Path")
                    }
                    LabeledContent {
                        Text(currentURL!.query() ?? "-")
                    } label: {
                        Text("Query")
                    }
                }
            }.scrollContentBackground(.hidden)
        }
        .padding()
        .onOpenURL(perform: { incomingUrl in
            handleIncomingURL(incomingUrl)
        })
    }
    
    private func handleIncomingURL(_ url: URL) {
        print("App was opened via URL: \(url)")
        urlLabel = url.absoluteString
        currentURL = url
    }
}

#Preview {
    ContentView()
}
