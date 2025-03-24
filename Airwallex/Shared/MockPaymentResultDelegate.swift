//
//  MockPaymentResultDelegate.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Core

class MockPaymentResultDelegate: UIViewController, AWXPaymentResultDelegate {
    private(set) var status = AirwallexPaymentStatus.notStarted
    private(set) weak var viewController: UIViewController?
    private(set) var error: Error?
    private(set) var consentId: String?
    private(set) var presentedViewControllerSpy: UIViewController?
 
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
