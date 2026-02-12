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

    static func topMostViewController(from root: UIViewController?) -> UIViewController? {
        if let presented = root?.presentedViewController {
            return topMostViewController(from: presented)
        }
        if let nav = root as? UINavigationController {
            return topMostViewController(from: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topMostViewController(from: tab.selectedViewController)
        }
        return root
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
