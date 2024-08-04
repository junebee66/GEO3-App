//
//  WebView.swift
//  MoGallery
//
//  Created by jht2 on 4/16/23.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    
    let request: URLRequest
    
    @EnvironmentObject var app: AppModel

    func update(key: String, value: Double) {
        guard let user = app.lobbyModel.currentUser else {
            return
        }
        print("update key", key, "value", value)
        user.stats[key] = value
        app.lobbyModel.updateUser(user: user);
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }

    func makeUIView(context: Context) -> WKWebView  {

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true;
        // webConfiguration.allowsAirPlayForMediaPlayback = true;
        // webConfiguration.allowsPictureInPictureMediaPlayback = true;
        webConfiguration.mediaTypesRequiringUserActionForPlayback = [];

        let webController = WKUserContentController()
        webController.add(context.coordinator, name: "dice")
        
        webConfiguration.userContentController = webController;

        let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.uiDelegate = context.coordinator
        wkWebView.navigationDelegate = context.coordinator

        return wkWebView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension WebView {
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        
        var parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            print("userContentController didReceive message", message)
            print("userContentController didReceive message.name", message.name)
            print("userContentController didReceive message.body", message.body)
            guard message.name == "dice" else {
                return
            }
            guard let body = message.body as? NSDictionary else {
                return
            }
            print("userContentController body", body)
            guard let stats = body["stats"] as? NSDictionary else {
                return
            }
            print("userContentController stats", stats)
            if let init_lapse = stats["init_lapse"] as? Double {
                print("userContentController init_lapse", init_lapse)
                parent.update( key: "init_lapse", value: init_lapse )
            }
            if let load_lapse = stats["load_lapse"] as? Double {
                print("userContentController load_lapse", load_lapse)
                parent.update( key: "load_lapse", value: load_lapse )
            }
            // load_lapse
        }
        
        func webView(
            _ webView: WKWebView,
            requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            print("requestDeviceOrientationAndMotionPermissionFor origin", origin)
            decisionHandler(.grant);
        }
        
        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            print("requestMediaCapturePermissionFor origin type", type.rawValue)
            // print("requestMediaCapturePermissionFor origin", origin, "type", type.rawValue)
            decisionHandler(.grant);
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            preferences: WKWebpagePreferences,
            decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
        ) {
            print("decidePolicyFor preferences navigationAction")
            // print("decidePolicyFor preferences navigationAction", navigationAction, "preferences", preferences)
            decisionHandler(.allow, preferences)
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            print("decidePolicyFor navigationAction")
            // print("decidePolicyFor navigationAction", navigationAction)
            decisionHandler(.allow)
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationResponse: WKNavigationResponse,
            decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
        ) {
            print("decidePolicyFor navigationResponse")
            // print("decidePolicyFor navigationResponse", navigationResponse)
            decisionHandler(.allow)
        }
    }

}

// https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers

