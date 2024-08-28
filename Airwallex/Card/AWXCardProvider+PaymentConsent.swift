//
//  AWXCardProvider+PaymentConsent.swift
//  Card
//
//  Created by Hector.Huang on 2024/8/27.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public extension AWXCardProvider {
    @objc func confirmPaymentIntentWithPaymentConsent(_ paymentConsent: AWXPaymentConsent) {
        guard let hostViewController = delegate?.hostViewController?() else {
            fatalError("hostViewController of AWXProviderDelegate is not provided")
        }
        if paymentConsent.paymentMethod?.card?.numberType == "PAN" {
            let controller = AWXPaymentViewController(nibName: nil, bundle: nil)
            controller.session = session
            controller.paymentConsent = paymentConsent
            controller.delegate = self
            
            if let image = UIImage(named: "close", in: Bundle.resource()) {
                controller.navigationItem.leftBarButtonItem = .init(image: image, style: .plain, target: self, action: #selector(close))
            }
            
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.isModalInPresentation = true
            hostViewController.present(navigationController, animated: true)
        } else {
            confirmPaymentIntent(withPaymentConsentId: paymentConsent.id)
        }
    }
    
    @objc private func close() {
        if let hostVC = delegate?.hostViewController?(), let navController = hostVC.presentedViewController as? UINavigationController {
            if navController.viewControllers.contains(where: { $0 is AWXPaymentViewController }) {
                navController.dismiss(animated: true) { self.delegate?.provider(self, didCompleteWith: .cancel, error: nil) }
            }
        }
    }
}

extension AWXCardProvider: AWXPaymentResultDelegate {
    public func paymentViewController(_ controller: UIViewController, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        controller.dismiss(animated: true) {
            self.delegate?.provider(self, didCompleteWith: status, error: error)
        }
    }
    
    public func paymentViewController(_ controller: UIViewController, didCompleteWithPaymentConsentId paymentConsentId: String) {
        delegate?.provider?(self, didCompleteWithPaymentConsentId: paymentConsentId)
    }
}
