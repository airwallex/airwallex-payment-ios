//
//  MockPaymentResultDelegate.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
#if canImport(AirwallexPaymentSheet)
import AirwallexPaymentSheet
#endif
import UIKit

class MockPaymentResultDelegate: UIViewController, AWXPaymentResultDelegate {
    var status: AirwallexPaymentStatus?
    weak var viewController: UIViewController?
    var error: Error?
    var consentId: String?
    var presentedViewControllerSpy: UIViewController?
    var paymentMethod: String?

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

#if canImport(AirwallexPaymentSheet)
extension MockPaymentResultDelegate: AWXPaymentElementDelegate {
    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteFor paymentMethod: String,
        with status: AirwallexPaymentStatus,
        error: Error?
    ) {
        self.paymentMethod = paymentMethod
        self.status = status
        self.error = error
    }

    func paymentElement(
        _ element: AWXPaymentElement,
        didCompleteFor paymentMethod: String,
        withPaymentConsentId paymentConsentId: String
    ) {
        self.paymentMethod = paymentMethod
        self.consentId = paymentConsentId
    }
}

/// A mock delegate that implements the optional `onProcessingStateChangedFor` method.
class MockProcessingStateDelegate: MockPaymentResultDelegate {
    var processingStateChangedCalled = false
    var processingStatePaymentMethod: String?
    var processingStateIsProcessing: Bool?

    func paymentElement(
        _ element: AWXPaymentElement,
        onProcessingStateChangedFor paymentMethod: String,
        isProcessing: Bool
    ) {
        processingStateChangedCalled = true
        processingStatePaymentMethod = paymentMethod
        processingStateIsProcessing = isProcessing
    }
}
#endif
