//
//  ErrorView.swift
//  APIManager
//
//  Created by Seth Battis on 4/16/24.
//

import SwiftUI

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            Text(String(describing: error))
        }
    }
    
    init(_ error: Error) {
        self.error = error
    }
}

#Preview {
    ErrorView(APIManager.APIError.APIResponse(error: "Bad things happened"))
}
