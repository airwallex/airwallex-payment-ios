//
//  MockApplePayProvider.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment

class MockApplePayProvider: AWXDefaultProvider, ApplePayProviderProtocol {
    var startPaymentCalled = false
    var cancelPaymentOnDismissValue = false
    var shouldSucceed = true
    
    init(delegate: AWXProviderDelegate,
         session: AWXSession,
         methodType: AWXPaymentMethodType? = nil,
         shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
        super.init(delegate: delegate, session: session, paymentMethodType: methodType)
    }
    
    func startPayment(cancelPaymentOnDismiss: Bool) throws {
        startPaymentCalled = true
        cancelPaymentOnDismissValue = cancelPaymentOnDismiss
        
        // Simulate the flow by calling delegate methods
        Task { @MainActor in
            delegate?.providerDidStartRequest(self)
            
            // Simulate success or failure immediately
            if shouldSucceed {
                delegate?.provider(self, didCompleteWith: .success, error: nil)
            } else {
                let error = NSError(domain: "MockApplePayProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock Apple Pay failure"])
                delegate?.provider(self, didCompleteWith: .failure, error: error)
            }
            
            delegate?.providerDidEndRequest(self)
        }
    }
}
