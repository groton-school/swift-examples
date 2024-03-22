//
//  IntView.swift
//  NavigationStack
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct IntView: View {
    let int: Int
    
    var body: some View {
        VStack {
            Text("An integer").padding().bold()
            Text(String(int))
        }
    }
}

#Preview {
    IntView(int: 1024)
}
