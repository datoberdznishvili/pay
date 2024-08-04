//
//  WebView.swift
//
//
//  Created by Giga Khizanishvili on 05.08.24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let onNavigation: (URL) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onNavigation: onNavigation)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var onNavigation: (URL) -> Void

        init(_ parent: WebView, onNavigation: @escaping (URL) -> Void) {
            self.parent = parent
            self.onNavigation = onNavigation
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                onNavigation(url)
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url {
                onNavigation(url)
            }
        }
    }
}

