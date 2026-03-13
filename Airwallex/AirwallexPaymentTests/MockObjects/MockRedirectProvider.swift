//
//  MockRedirectProvider.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
import Foundation

class MockRedirectProvider: AWXDefaultProvider, RedirectProviderProtocol {
    var startPaymentCalled = false
    var shouldSucceed = true
    
    var lastPaymentMethodUsed: String?
    var lastAdditionalInfoUsed: [String: String]?
    
    init(delegate: AWXProviderDelegate,
         session: AWXSession,
         methodType: AWXPaymentMethodType? = nil,
         shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
        super.init(delegate: delegate, session: session, paymentMethodType: methodType)
    }
    
    func confirmPaymentIntent(with paymentMethod: String, additionalInfo: [String: String]?) {
        startPaymentCalled = true
        lastPaymentMethodUsed = paymentMethod
        lastAdditionalInfoUsed = additionalInfo
        
        // Simulate the flow by calling delegate methods
        Task { @MainActor in
            delegate?.providerDidStartRequest(self)
            
            // Simulate success or failure immediately
            if shouldSucceed {
                delegate?.provider(self, didCompleteWith: .success, error: nil)
            } else {
                let error = NSError(domain: "MockRedirectProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock redirect payment failure"])
                delegate?.provider(self, didCompleteWith: .failure, error: error)
            }
            
            delegate?.providerDidEndRequest(self)
        }
    }
    
    func validate(name: String) throws {
        // No implementation needed for mock
        if name.isEmpty {
            throw NSError(domain: "MockRedirectProvider", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid payment method name"])
        }
    }
}
