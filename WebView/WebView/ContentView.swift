//
//  ContentView.swift
//  WebView
//
//  Created by Seth Battis on 3/21/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            WebView(url: URL(string: "https://www.groton.org")!)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
