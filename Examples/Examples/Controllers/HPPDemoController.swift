//
//  HPPDemoController.swift
//  Examples
//
//  Created by Weiping Li on 2025/08/08.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Airwallex
import UIKit
import WebKit

@MainActor
class HPPDemoController: NSObject {
    
    lazy var webView: WKWebView = {
        // Create WKWebView configuration
        let configuration = WKWebViewConfiguration()
        
        // Enable JavaScript
        configuration.preferences.javaScriptEnabled = true
        
        // Create WKWebView with configuration
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        return webView
    }()
    
    weak var viewController: UIViewController?
    
    private var isWebViewLoaded = false
    private var webViewLoadingContinuation: CheckedContinuation<Void, Error>?
    
    override init() {
        super.init()
        
        loadLocalHTML()
    }
    
    func getURLForHPP(intentId: String,
                      clientSecret: String,
                      currency: String,
                      countryCode: String,
                      returnURL: String) async throws -> URL {
        // Wait for the webView to finish loading
        try await waitForWebViewToLoad()
        
        // Set the intent_id, client_secret, and currency on the window object
        let script1 = """
                    window.intent_id = "\(intentId)";
                    window.client_secret = "\(clientSecret)";
                    window.currency = "\(currency)";
                    window.country_code = "\(countryCode)";
                    window.return_url = "\(returnURL)"
                    console.log("Payment intent details set on window object");
                """
        
        try await webView.evaluateJavaScript(script1)
        
        // Get URL for HPP
        let script2 = "window.redirectHppForCheckout()"
        let result = try await webView.evaluateJavaScript(script2)
        guard let result = result as? String,
              let url = URL(string: result) else {
            throw NSError.airwallexError(localizedMessage: "Invalid URL: \(String(describing: result))")
        }
        return url
    }
}

private extension HPPDemoController {
    func loadLocalHTML() {
        // Reset loading state
        isWebViewLoaded = false
        // Get the URL to the local HTML file
        if let htmlURL = Bundle.main.url(forResource: "demo", withExtension: "html", subdirectory: nil) {
            // Load the HTML file
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        } else {
            print("Error: Could not find demo.html in the bundle")
        }
    }
    
    func waitForWebViewToLoad() async throws {
        // If already loaded, return immediately
        if isWebViewLoaded {
            return
        }
        
        // Otherwise, wait for the didFinish delegate to be called
        try await withCheckedThrowingContinuation { continuation in
            // Store the continuation to be resumed in the delegate method
            webViewLoadingContinuation = continuation
            
            // Add a timeout to prevent indefinite waiting
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                if let continuation = self?.webViewLoadingContinuation {
                    self?.webViewLoadingContinuation = nil
                    continuation.resume(throwing: NSError.airwallexError(localizedMessage: "Timeout waiting for webView to load"))
                }
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension HPPDemoController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        isWebViewLoaded = true
        
        // Resume any waiting continuation
        if let continuation = webViewLoadingContinuation {
            continuation.resume()
            webViewLoadingContinuation = nil
        }
    }
}
