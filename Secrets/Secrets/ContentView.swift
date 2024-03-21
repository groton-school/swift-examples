//
//  ContentView.swift
//  Secrets
//
//  Created by Seth Battis on 3/21/24.
//

import SwiftUI
import Keys

struct ContentView: View {
    var body: some View {
        let keys = Keys.OrgGrotonSwiftExamplesSecretsKeys()
        
        VStack {
            Form {
                LabeledContent {
                    Text(keys.secretOne)
                } label: {
                    Text("secretOne")
                }
                LabeledContent {
                    Text(keys.secretTwo)
                } label: {
                    Text("SecretTwo")
                }
                LabeledContent {
                    Text(keys.sECRET_THREE)
                } label: {
                    Text("SECRET_THREE")
                }
            }.scrollContentBackground(.hidden)

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
