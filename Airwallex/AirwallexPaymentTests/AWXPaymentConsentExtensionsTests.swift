//
//  AWXPaymentConsentExtensionsTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 29/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
import AirwallexCore
@_spi(AWX) @testable import AirwallexPayment

class AWXPaymentConsentExtensionsTests: XCTestCase {
    
    private var paymentConsent: AWXPaymentConsent!
    
    override func setUp() {
        super.setUp()
        paymentConsent = AWXPaymentConsent()
    }
    
    override func tearDown() {
        paymentConsent = nil
        super.tearDown()
    }
    
    func testIsCITConsent_WhenNextTriggeredByIsCustomerType_ReturnsTrue() {
        // Arrange
        paymentConsent.nextTriggeredBy = FormatNextTriggerByType(.customerType)
        
        // Act & Assert
        XCTAssertTrue(paymentConsent.isCITConsent, "isCITConsent should return true when nextTriggeredBy is customerType")
    }
    
    func testIsCITConsent_WhenNextTriggeredByIsNotCustomerType_ReturnsFalse() {
        // Arrange
        paymentConsent.nextTriggeredBy = FormatNextTriggerByType(.merchantType)
        
        // Act & Assert
        XCTAssertFalse(paymentConsent.isCITConsent, "isCITConsent should return false when nextTriggeredBy is not customerType")
        
        // Additional check with empty value
        paymentConsent.nextTriggeredBy = ""
        XCTAssertFalse(paymentConsent.isCITConsent, "isCITConsent should return false when nextTriggeredBy is nil")
    }
    
    func testIsMITConsent_WhenNextTriggeredByIsMerchantType_ReturnsTrue() {
        // Arrange
        paymentConsent.nextTriggeredBy = FormatNextTriggerByType(.merchantType)
        
        // Act & Assert
        XCTAssertTrue(paymentConsent.isMITConsent, "isMITConsent should return true when nextTriggeredBy is merchantType")
    }
    
    func testIsMITConsent_WhenNextTriggeredByIsNotMerchantType_ReturnsFalse() {
        // Arrange
        paymentConsent.nextTriggeredBy = FormatNextTriggerByType(.customerType)
        
        // Act & Assert
        XCTAssertFalse(paymentConsent.isMITConsent, "isMITConsent should return false when nextTriggeredBy is not merchantType")
        
        // Additional check with empty value
        paymentConsent.nextTriggeredBy = ""
        XCTAssertFalse(paymentConsent.isMITConsent, "isMITConsent should return false when nextTriggeredBy is nil")
    }
}
