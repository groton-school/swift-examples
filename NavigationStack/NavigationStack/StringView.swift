//
//  StringView.swift
//  NavigationStack
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct StringView: View {
    let string: String
    
    var body: some View {
        VStack {
            Text("A string").padding().bold()
            Text(string)
        }
    }
}

#Preview {
    StringView(string: "Argle Bargle")
}
