//
//  WebViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/12.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Combine
import UIKit
@preconcurrency import WebKit

class WebViewController: UIViewController {
    private var webView: WKWebView!

    let url: String
    private(set) var referer: String
    var isPopupWebView = false

    init(url: String, referer: String) {
        self.url = url
        self.referer = referer
        super.init(nibName: nil, bundle: nil)
    }

    /// Initialize with an external WKWebView (used for popup support, e.g., Google Pay)
    /// https://developers.google.com/pay/api/web/guides/recipes/using-ios-wkwebview
    init(webView: WKWebView) {
        self.url = ""
        self.referer = ""
        super.init(nibName: nil, bundle: nil)
        self.webView = webView
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create webView if not already provided (normal case vs popup case)
        if webView == nil {
            let config = WKWebViewConfiguration()
            // Append GOOGLE_PAY_SUPPORTED to user agent for Google Pay isReadyToPay API
            config.applicationNameForUserAgent = "Airwallex-iOS-SDK" + " GOOGLE_PAY_SUPPORTED"
            webView = WKWebView(frame: .zero, configuration: config)
            webView.uiDelegate = self
            webView.navigationDelegate = self
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
        }
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        let constraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)

        cancellable = webView.publisher(for: \.title)
            .assign(to: \.title, on: self)

        if !url.isEmpty {
            load()
        }
    }

    private var webViewDidCloseHandled: Bool = false

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isPopupWebView && !webViewDidCloseHandled else { return }
        // Only execute when actually being dismissed/popped, not when covered by another VC
        guard isBeingDismissed || isMovingFromParent else { return }
        webViewDidCloseHandled = true
        // when dismissed or popped by user
        // force status sync (to dismiss GPay mask in original webView)
        webView.evaluateJavaScript("window.close()") { object, error in
            if let error {
                print(error)
            }
        }
    }

    func load() {
        guard !url.isEmpty, let requestUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        
        if let referUrl = URL(string: referer), let host = referUrl.host {
            referer = "\(host)://"
        }
        
        request.setValue(referer, forHTTPHeaderField: "Referer")
        request.httpMethod = "GET"
        
        webView.load(request)
    }
}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let absoluteString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }

        let customSchemes = ["weixin://wap/pay?", "alipay://", "alipayhk://", "airwallexcheckout://", "alipays://", "kakaotalk://"]

        if customSchemes.contains(where: { absoluteString.hasPrefix($0) }),
            let url = URL(string: absoluteString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate (Popup support for Google Pay)
extension WebViewController: WKUIDelegate {

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Only handle popup requests (when targetFrame is nil)
        guard navigationAction.targetFrame == nil else { return nil }

        let popupWebView = WKWebView(frame: .zero, configuration: configuration)
        popupWebView.customUserAgent = "Airwallex-iOS-SDK" + " GOOGLE_PAY_SUPPORTED"

        let popupViewController = WebViewController(webView: popupWebView)
        popupViewController.isPopupWebView = true
        present(popupViewController, animated: true)

        return popupWebView
    }

    func webViewDidClose(_ webView: WKWebView) {
        guard !webViewDidCloseHandled else { return }
        webViewDidCloseHandled = true
        if let presentingViewController {
            presentingViewController.dismiss(animated: true)
        } else if let navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
