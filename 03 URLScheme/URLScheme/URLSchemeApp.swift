//
//  URLSchemeApp.swift
//  URLScheme
//
//  Created by Seth Battis on 3/21/24.
//

import SwiftUI

@main
struct URLSchemeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                print(url.absoluteString)
            })
        }
    }
}
