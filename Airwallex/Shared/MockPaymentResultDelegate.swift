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
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        presentedViewControllerSpy = viewControllerToPresent
    }
}
