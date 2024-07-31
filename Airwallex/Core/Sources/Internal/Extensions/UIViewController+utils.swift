//
//  UIViewController+utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc
public extension UIViewController {
    static var activityIndicator: UIActivityIndicatorView?

    func enableTapToEndEditing() {
        let ges = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        ges.cancelsTouchesInView = false
        view.addGestureRecognizer(ges)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func startAnimating() {
        if Self.activityIndicator == nil {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true

            Self.activityIndicator = activityIndicator
            view.addSubview(activityIndicator)
        }

        if let activityIndicator = Self.activityIndicator {
            view.bringSubviewToFront(activityIndicator)
            activityIndicator.startAnimating()
        }
    }

    func stopAnimating() {
        if let activityIndicator = Self.activityIndicator {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            Self.activityIndicator = nil
        }
    }
}
