//
//  MockPaymentResultDelegate.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import AirwallexCore

class MockPaymentResultDelegate: UIViewController, AWXPaymentResultDelegate {
    var status: AirwallexPaymentStatus? = nil
    weak var viewController: UIViewController?
    var error: Error?
    var consentId: String?
    var presentedViewControllerSpy: UIViewController?
 
    func paymentViewController(_ controller: UIViewController?, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        self.status = status
        self.viewController = controller
        self.error = error
    }
    
    func paymentViewController(_ controller: UIViewController?, didCompleteWithPaymentConsentId paymentConsentId: String) {
        self.viewController = controller
        self.consentId = paymentConsentId
    }
    
    override var presentedViewController: UIViewController? {
        return self
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllerSpy = viewControllerToPresent
        completion?()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllerSpy = nil
        completion?()
    }
}
