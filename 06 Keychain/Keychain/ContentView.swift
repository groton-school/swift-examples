//
//  ContentView.swift
//  Keychain
//
//  Created by Seth Battis on 4/7/24.
//

import SwiftUI

struct ContentView: View {
    @State var secret: String
    @State var saved: Bool
    @State var lastSave: Date?
    private let tag = "org.groton.swift-examples.keychain.secret"

    
    var body: some View {
        Form {
            Section {
                TextEditor(text: $secret)
                Button(action: {
                    do {
                        if saved {
                            try Keychain.update(secret, tag: tag)
                        } else {
                            try Keychain.save(secret, tag: tag)
                            saved = true
                        }
                        lastSave = Date.now
                    } catch {
                        print(error)
                    }
                }, label: {
                    Text("Save Secret")
                })
            }
            if lastSave != nil {
                Section(header: Text("Last saved")) {
                    Text(lastSave!, style: .relative)
                }
            }
            if saved {
                Section(header: Text("Secret is in keychain")) {
                    Button(action: {
                        do {
                            try Keychain.delete(tag: tag)
                            saved = false
                            secret = ""
                            lastSave = nil
                        } catch {
                            print(error)
                        }
                    }, label: {
                        Text("Delete Secret")
                    })
                }
            }
        }
    }
    
    init() {
        do {
            secret = try Keychain.get(tag: tag)
            saved = true
        } catch {
            print(error)
            secret = ""
            saved = false
        }
    }
}

#Preview {
    ContentView()
}
