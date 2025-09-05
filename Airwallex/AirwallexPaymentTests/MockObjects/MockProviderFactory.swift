//
//  MockProviderFactory.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment

class MockProviderFactory: ProviderFactoryProtocol {
    
    var mockApplePayProvider: ApplePayProviderProtocol?
    var mockCardProvider: CardProviderProtocol?
    var mockRedirectProvider: RedirectProviderProtocol?
    
    var applePayProviderCalled = false
    var cardProviderCalled = false
    var redirectProviderCalled = false
    
    func applePayProvider(delegate: any AWXProviderDelegate,
                          session: AWXSession,
                          type: AWXPaymentMethodType?) -> ApplePayProviderProtocol {
        applePayProviderCalled = true
        
        if let mockProvider = mockApplePayProvider {
            return mockProvider
        }
        
        // Return a default mock if none was provided
        return MockApplePayProvider(
            delegate: delegate,
            session: session,
            methodType: type
        )
    }
    
    func cardProvider(delegate: any AWXProviderDelegate,
                      session: AWXSession,
                      type: AWXPaymentMethodType?) -> CardProviderProtocol {
        cardProviderCalled = true
        
        if let mockProvider = mockCardProvider {
            return mockProvider
        }
        
        // Use the real factory as fallback
        return MockCardProvider(
            delegate: delegate,
            session: session,
            methodType: type
        )
    }
    
    func redirectProvider(delegate: any AWXProviderDelegate,
                          session: AWXSession,
                          type: AWXPaymentMethodType?) -> RedirectProviderProtocol {
        redirectProviderCalled = true
        
        if let mockProvider = mockRedirectProvider {
            return mockProvider
        }
        
        // Use the real factory as fallback
        return MockRedirectProvider(
            delegate: delegate,
            session: session,
            methodType: type
        )
    }
    
    // Helper method to reset tracking state
    func reset() {
        applePayProviderCalled = false
        cardProviderCalled = false
        redirectProviderCalled = false
        mockApplePayProvider = nil
        mockCardProvider = nil
        mockRedirectProvider = nil
    }
}
