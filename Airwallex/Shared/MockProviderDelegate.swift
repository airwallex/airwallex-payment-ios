//
//  MockProviderDelegate.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
import UIKit

class MockProviderDelegate: UIViewController, AWXProviderDelegate {
    // Properties to track delegate calls
    var didStartRequest = 0
    var didEndRequest = 0
    var completionStatus: AirwallexPaymentStatus?
    var completionError: Error?
    var paymentConsentId: String?
    var paymentIntentId: String?
    
    func providerDidStartRequest(_ provider: AWXDefaultProvider) {
        didStartRequest += 1
    }
    
    func providerDidEndRequest(_ provider: AWXDefaultProvider) {
        didEndRequest += 1
    }
    
    func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        self.paymentIntentId = paymentIntentId
    }
    
    func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        completionStatus = status
        completionError = error
    }
    
    func provider(_ provider: AWXDefaultProvider, didCompleteWithPaymentConsentId consentId: String) {
        paymentConsentId = consentId
    }
    
    // Additional required methods with empty implementations
    func hostViewController() -> UIViewController {
        return self
    }
    
    func provider(_ provider: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction) {
        // Empty implementation for testing
    }
    
    func provider(_ provider: AWXDefaultProvider, shouldInsert controller: UIViewController) {
        // Empty implementation for testing
    }
    
    func provider(_ provider: AWXDefaultProvider, shouldPresent controller: UIViewController?, forceToDismiss: Bool, withAnimation: Bool) {
        // Empty implementation for testing
    }
    
    // Reset the tracking state for tests
    func reset() {
        didStartRequest = 0
        didEndRequest = 0
        completionStatus = nil
        completionError = nil
        paymentConsentId = nil
        paymentIntentId = nil
    }
    
    var presentedViewControllerSpy: UIViewController?
    
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
