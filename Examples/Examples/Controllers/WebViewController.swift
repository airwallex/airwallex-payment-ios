//
//  WebViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/12.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
@preconcurrency import WebKit
import Combine

class WebViewController: UIViewController {
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    let url: String
    private(set) var referer: String
    
    init(url: String, referer: String) {
        self.url = url
        self.referer = referer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cancellable: AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        load()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "title")
    }
    
    func load() {
        guard !url.isEmpty, let requestUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        
        if let referUrl = URL(string: referer), let host = referUrl.host {
            referer = "\(host)://"
        }
        
        request.setValue(referer, forHTTPHeaderField: "Referer")
        request.setValue("Airwallex-iOS-SDK", forHTTPHeaderField: "User-Agent")
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
