//
//  UIViewController+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/22.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

@_spi(AWX) public extension UIViewController {
    func startLoading() {
        view.startLoading()
    }

    func stopLoading() {
        view.stopLoading()
    }

    var isLoading: Bool {
        view.isLoading
    }
}

@_spi(AWX) public extension UIViewController {
    static var topMost: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene
        let keyWindow: UIWindow?
        if #available(iOS 15.0, *) {
            keyWindow = windowScene?.keyWindow
        } else {
            keyWindow = windowScene?.windows.first(where: { $0.isKeyWindow })
        }
        let rootVC = keyWindow?.rootViewController

        return UIViewController.topMost(from: rootVC)
    }

    static func topMost(from rootVC: UIViewController?) -> UIViewController? {
        if let presented = rootVC?.presentedViewController {
            return topMost(from: presented)
        }
        if let nav = rootVC as? UINavigationController {
            return topMost(from: nav.visibleViewController)
        }
        if let tab = rootVC as? UITabBarController {
            return topMost(from: tab.selectedViewController)
        }
        return rootVC
    }
}

@_spi(AWX) public extension UIView {
    private static let tagForActivityIndicator = Int.random(in: Int.max/2...Int.max)
    func startLoading() {
        isUserInteractionEnabled = false
        guard let indicator = viewWithTag(Self.tagForActivityIndicator) as? LoadingSpinnerView  else {
            let activityIndicator = LoadingSpinnerView(size: .medium)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.tag = Self.tagForActivityIndicator
            addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
            
            activityIndicator.startAnimating()
            activityIndicator.accessibilityIdentifier = "loadingSpinnerView"
            return
        }
        bringSubviewToFront(indicator)
        indicator.startAnimating()
    }
    
    func stopLoading() {
        isUserInteractionEnabled = true
        (viewWithTag(Self.tagForActivityIndicator) as? LoadingSpinnerView)?.stopAnimating()
    }
    
    var isLoading: Bool {
        (viewWithTag(Self.tagForActivityIndicator) as? LoadingSpinnerView)?.isAnimating ?? false
    }
}
