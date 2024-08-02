//
//  UIViewController+utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

private let activityIndicatorTag = 96483

@objc
public extension UIViewController {
    func enableTapToEndEditing() {
        let ges = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        ges.cancelsTouchesInView = false
        view.addGestureRecognizer(ges)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    func startAnimating() {
        if view.viewWithTag(activityIndicatorTag) == nil {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.tag = activityIndicatorTag

            view.addSubview(activityIndicator)
            view.bringSubviewToFront(activityIndicator)
            activityIndicator.startAnimating()
        }
    }

    func stopAnimating() {
        if let activityIndicator = view.viewWithTag(activityIndicatorTag) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}
