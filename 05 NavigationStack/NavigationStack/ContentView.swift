//
//  ContentView.swift
//  NavigationStack
//
//  Created by Seth Battis on 3/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink(value: "foo", label: { Text("Foo")
                })
                NavigationLink(value: "bar", label: {
                    Text("Bar")
                })
                NavigationLink(value: 123, label:{
                    Text("123")
                })
                NavigationLink(value: MyStruct(x: 42, y: "Argle Bargle"), label:{
                    Text("42/Argle Bargle")
                })
                Button(action: {
                    path.append("Programmatically added by a button")
                }, label: {
                    Text("Button")
                })
            }.navigationDestination(for: String.self) {textValue in
                StringView(string: textValue)
            }.navigationDestination(for: Int.self , destination: {int in
                IntView(int: int)
            }).navigationDestination(for: MyStruct.self) {myStruct in
                MyStructView(myStruct: myStruct)
            }
        }
    }
}

#Preview {
    ContentView()
}
