//
//  UIViewController+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/22.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

@_spi(AWX) public extension UIViewController {
    
    private static let tagForActivityIndicator = Int.random(in: Int.max/2...Int.max)
    func startLoading() {
        view.isUserInteractionEnabled = false
        guard let indicator = view.viewWithTag(Self.tagForActivityIndicator) as? LoadingSpinnerView  else {
            let activityIndicator = LoadingSpinnerView(size: .medium)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.tag = Self.tagForActivityIndicator
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
            
            activityIndicator.startAnimating()
            activityIndicator.accessibilityIdentifier = "loadingSpinnerView"
            return
        }
        view.bringSubviewToFront(indicator)
        indicator.startAnimating()
    }
    
    func stopLoading() {
        view.isUserInteractionEnabled = true
        (view.viewWithTag(Self.tagForActivityIndicator) as? LoadingSpinnerView)?.stopAnimating()
    }
    
    var isLoading: Bool {
        (view.viewWithTag(Self.tagForActivityIndicator) as? LoadingSpinnerView)?.isAnimating ?? false
    }
}
