//
//  UIViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

extension UIViewController {
    
    func customizeNavigationBackIndicator() {
        let offset: CGFloat = 6
        let image = UIImage(named: "arrow_left")!
        var size = image.size
        size.width += offset
        let renderer = UIGraphicsImageRenderer(size: size)
        let newImage = renderer.image { context in
            image.draw(at: .init(x: offset, y: 0))
        }.withTintColor(.awxTextPrimary, renderingMode: .alwaysOriginal)
        navigationController?.navigationBar.backIndicatorImage = newImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = newImage
    }
    
    func customizeNavigationBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
    
    func showAlert(message: String?, title: String? = nil, action: (() -> Void)? = nil) {
        guard title != nil || message != nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: NSLocalizedString("OK", comment: "SDK DEMO"), style: .cancel) { _ in
            action?()
        }
        alert.addAction(closeAction)
        present(alert, animated: true)
    }
    
    func showOptions<T>(_ options: [T], sender: UIView?, completion: @escaping (Int, T) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for (index, option) in options.enumerated() {
            let action = UIAlertAction(
                title: String(describing: option),
                style: .default,
                handler: { _ in
                    completion(index, option)
                }
            )
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "SDK Demo"), style: .cancel)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
}

extension UIViewController {
    private static let tagForActivityIndicator = 2025
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
}
