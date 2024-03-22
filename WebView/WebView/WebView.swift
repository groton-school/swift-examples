//
//  WebView.swift
//  WebView
//
//  Created by Seth Battis on 3/21/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    let webView = WKWebView()
    let url: URL
        
     func makeUIView(context: Context) -> some WKWebView {
         let request = URLRequest(url: url)
         webView.uiDelegate = context.coordinator
         webView.navigationDelegate = context.coordinator
         webView.load(request)
         return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func reload() {
        webView.reload()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            // if the request is a non-http(s) schema, then have the UIApplication handle
            // opening the request
            if let url = navigationAction.request.url,
                !url.absoluteString.hasPrefix("http://"),
                !url.absoluteString.hasPrefix("https://"),
                UIApplication.shared.canOpenURL(url) {

                // have UIApplication handle the url (sms:, tel:, mailto:, ...)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

                // cancel the request (handled by UIApplication)
                decisionHandler(.cancel)
            }
            else {
                // allow the request
                decisionHandler(.allow)
            }
        }
    }
}
