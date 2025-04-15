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
        guard let indicator = view.viewWithTag(Self.tagForActivityIndicator) as? UIActivityIndicatorView  else {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.hidesWhenStopped = true
            activityIndicator.tag = Self.tagForActivityIndicator
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
            
            activityIndicator.startAnimating()
            return
        }
        view.bringSubviewToFront(indicator)
        indicator.startAnimating()
    }
    
    func stopLoading() {
        view.isUserInteractionEnabled = true
        (view.viewWithTag(Self.tagForActivityIndicator) as? UIActivityIndicatorView)?.stopAnimating()
    }
    
    var isLoading: Bool {
        (view.viewWithTag(Self.tagForActivityIndicator) as? UIActivityIndicatorView)?.isAnimating ?? false
    }
}
