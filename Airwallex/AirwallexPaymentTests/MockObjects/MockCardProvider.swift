//
//  MockCardProvider.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment

class MockCardProvider: AWXDefaultProvider, CardProviderProtocol {
    var startPaymentCalled = false
    var startConsentPaymentCalled = false
    var shouldSucceed = true
    
    var lastCardUsed: AWXCard?
    var lastBillingUsed: AWXPlaceDetails?
    var lastSaveCardValue = false
    var lastConsentUsed: AWXPaymentConsent?
    var lastConsentIdUsed: String?
    
    init(delegate: AWXProviderDelegate,
         session: AWXSession,
         methodType: AWXPaymentMethodType? = nil,
         shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
        super.init(delegate: delegate, session: session, paymentMethodType: methodType)
    }
    
    func confirmIntentWithCard(_ card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool) async {
        startPaymentCalled = true
        lastCardUsed = card
        lastBillingUsed = billing
        lastSaveCardValue = saveCard
        
        // Simulate the flow by calling delegate methods
        await MainActor.run {
            delegate?.providerDidStartRequest(self)
            
            // Simulate success or failure immediately
            if shouldSucceed {
                delegate?.provider(self, didCompleteWith: .success, error: nil)
            } else {
                let error = NSError(domain: "MockCardProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock card payment failure"])
                delegate?.provider(self, didCompleteWith: .failure, error: error)
            }
            
            delegate?.providerDidEndRequest(self)
        }
    }
    
    func confirmIntentWithConsent(_ consent: AWXPaymentConsent) async {
        startConsentPaymentCalled = true
        lastConsentUsed = consent
        
        // Simulate the flow by calling delegate methods
        await MainActor.run {
            delegate?.providerDidStartRequest(self)
            
            // Simulate success or failure immediately
            if shouldSucceed {
                delegate?.provider(self, didCompleteWith: .success, error: nil)
            } else {
                let error = NSError(domain: "MockCardProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock consent payment failure"])
                delegate?.provider(self, didCompleteWith: .failure, error: error)
            }
            
            delegate?.providerDidEndRequest(self)
        }
    }
    
    func confirmIntentWithConsent(_ consentId: String, requiresCVC: Bool) async {
        startConsentPaymentCalled = true
        lastConsentIdUsed = consentId
        
        // Simulate the flow by calling delegate methods
        await MainActor.run {
            delegate?.providerDidStartRequest(self)
            
            // Simulate success or failure immediately
            if shouldSucceed {
                delegate?.provider(self, didCompleteWith: .success, error: nil)
            } else {
                let error = NSError(domain: "MockCardProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock consent payment failure"])
                delegate?.provider(self, didCompleteWith: .failure, error: error)
            }
            
            delegate?.providerDidEndRequest(self)
        }
    }
}