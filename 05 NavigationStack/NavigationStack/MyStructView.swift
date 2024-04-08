//
//  MyStructView.swift
//  NavigationStack
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct MyStructView: View {
    let myStruct: MyStruct
    
    var body: some View {
        VStack {
            Text("A MyStruct").padding().bold()
            List {
                IntView(int: myStruct.x)
                StringView(string: myStruct.y)
            }
        }
    }
}

#Preview {
    MyStructView(myStruct: MyStruct(x: 123, y: "Foo"))
}
