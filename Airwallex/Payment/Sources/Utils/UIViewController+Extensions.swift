//
//  UIViewController+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/22.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

extension UIViewController {
    
    private static let tagForActivityIndicator = 9527
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
    
    func showAlert(title: String? = nil, message: String? = nil) {
        let alert = AWXAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", bundle: .payment, comment: ""), style: .cancel))
        present(alert, animated: true)
    }
}
