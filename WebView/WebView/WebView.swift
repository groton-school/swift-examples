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
    
    init(url: URL, clearData: Bool = false) {
        self.url = url
        if clearData {
            WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {})
        }
    }
            
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
        
        /**
         * Examine navigation actions to redirect non-HTTP URL schemes to app
         */
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if let url = navigationAction.request.url,
                !url.absoluteString.hasPrefix("http://"),
                !url.absoluteString.hasPrefix("https://"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            }
            else {
                decisionHandler(.allow)
            }
        }
    }
}
