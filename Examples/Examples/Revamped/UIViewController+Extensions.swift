//
//  UIViewController.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func customiseNavigationBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "arrow_left"),
            style: .plain,
            target: nil, action: nil
        )
        navigationController?.navigationBar.backIndicatorImage = UIImage()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
    }
    
    func showAlert(title: String? = nil, message: String? = nil) {
        guard title != nil || message != nil else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: NSLocalizedString("Close", comment: "SDK DEMO"), style: .cancel)
        alert.addAction(closeAction)
        present(alert, animated: true)
    }
}
