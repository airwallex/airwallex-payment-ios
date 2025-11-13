//
//  AWXSessionExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
import AirwallexCore

class AWXSessionExtensionTests: XCTestCase {
    
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.customerId = mockCustomerId
        mockPaymentIntent.clientSecret = mockClientSecret
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.amount = NSDecimalNumber(value: 1)
        mockPaymentIntent.currency = "AUD"
        
        AWXAPIClientConfiguration.shared().clientSecret = mockClientSecret
    }
    
    func testValidateOneOffSession() {
        let session = AWXOneOffSession()
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateOneOffSession_invalidCountryCode() {
        let session = AWXOneOffSession()
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        
        XCTAssertNoThrow(try session.validate())
        session.countryCode = "AA"
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidData(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateOneOffSessionWithoutPaymentIntent() {
        let session = AWXOneOffSession()
        session.countryCode = "AU"
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidData(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
        session.paymentIntent = mockPaymentIntent
        mockPaymentIntent.id = ""
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidPaymentIntent(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateOneOffSessionWithInvalidIntentId() {
        let session = AWXOneOffSession()
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        mockPaymentIntent.id = ""
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidPaymentIntent(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateOneOffSessionWithinvalidClientSecret() {
        let session = AWXOneOffSession()
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        mockPaymentIntent.clientSecret = ""
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidPaymentIntent(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringWithIntentSession() {
        let session = AWXRecurringWithIntentSession()
        session.paymentIntent = mockPaymentIntent
        session.countryCode = "AU"
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateRecurringWithIntentSessionWithoutCustomerId() {
        let session = AWXRecurringWithIntentSession()
        session.paymentIntent = mockPaymentIntent
        session.countryCode = "AU"
        XCTAssertNoThrow(try session.validate())
        
        mockPaymentIntent.customerId = nil
        
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidCustomerId(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringWithIntentSessionWithoutPaymentIntent() {
        let session = AWXRecurringWithIntentSession()
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        XCTAssertNoThrow(try session.validate())
        
        session.paymentIntent = nil
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidData(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringWithIntentSessionWithInvalidIntentId() {
        let session = AWXRecurringWithIntentSession()
        mockPaymentIntent.id = ""
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidPaymentIntent(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringWithIntentSessionWithInvalidClientSecret() {
        let session = AWXRecurringWithIntentSession()
        mockPaymentIntent.clientSecret = ""
        session.countryCode = "AU"
        session.paymentIntent = mockPaymentIntent
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidPaymentIntent(let message) = error,
                  message == error.localizedDescription else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringSession() {
        let session = AWXRecurringSession()
        session.countryCode = "AU"
        session.setCurrency("AUD")
        session.setAmount(NSDecimalNumber(value: 1))
        session.setCustomerId(mockCustomerId)
        
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateRecurringSession_invalidData() {
        let session = AWXRecurringSession()
        session.countryCode = "AU"
        session.setCustomerId(mockCustomerId)
        session.setCurrency("AUD")
        
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidData(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
        
        session.setAmount(NSDecimalNumber(value: 1))
        XCTAssertNoThrow(try session.validate())
        
        session.setCurrency("ZZZ")
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidData(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringSessionWithoutCustomerId() {
        let session = AWXRecurringSession()
        session.countryCode = "AU"
        session.setCurrency("AUD")
        session.setAmount(NSDecimalNumber(value: 1))
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidCustomerId(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateSession() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            returnURL: AWXThreeDSReturnURL
        )
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateSessionRecurring() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            paymentConsentOptions: .init(nextTriggeredBy: .customerType),
            returnURL: AWXThreeDSReturnURL
        )
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateSessionRecurringWithoutCustomerID() {
        mockPaymentIntent.customerId = nil
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            paymentConsentOptions: .init(nextTriggeredBy: .customerType),
            returnURL: AWXThreeDSReturnURL
        )
        XCTAssertThrowsError(try session.validate())
    }
    
    func testValidateSessionAmount() {
        mockPaymentIntent.amount = NSDecimalNumber(0)
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            returnURL: AWXThreeDSReturnURL
        )
        XCTAssertThrowsError(try session.validate())
    }
    
    func testValidateInvalidSessionType() {
        let session = AWXSession()
        
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidSessionType(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }

    func testValidateSessionWithoutPaymentIntentOrProvider() {
        // Test line 91: Session has neither paymentIntent nor paymentIntentProvider
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            returnURL: AWXThreeDSReturnURL
        )

        // Use reflection to set both paymentIntent and paymentIntentProvider to nil
        session.setValue(nil, forKey: "paymentIntent")
        session.setValue(nil, forKey: "paymentIntentProvider")

        XCTAssertThrowsError(try session.validate())
    }

    func testValidateSessionWithCurrencyMismatch() {
        // Test line 105: Currency mismatch between payment intent and terms of use
        mockPaymentIntent.currency = "USD"

        let termsOfUse = TermsOfUse(
            paymentAmountType: .fixed,
            paymentCurrency: "AUD"  // Different from payment intent currency
        )

        let consentOptions = PaymentConsentOptions(
            nextTriggeredBy: .merchantType,
            termsOfUse: termsOfUse
        )

        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            paymentConsentOptions: consentOptions,
            returnURL: AWXThreeDSReturnURL
        )

        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidData(let message) = error else {
                XCTFail("Expected invalidData error, got: \(error.localizedDescription)")
                return
            }
            XCTAssertEqual(message, "There is a currency mismatch between the payment intent and the terms of use")
        }
    }

    func testValidateSessionWithMatchingCurrency() {
        // Test that validation passes when currencies match
        mockPaymentIntent.currency = "USD"

        let termsOfUse = TermsOfUse(
            paymentAmountType: .fixed,
            paymentCurrency: "USD"  // Same as payment intent currency
        )

        let consentOptions = PaymentConsentOptions(
            nextTriggeredBy: .merchantType,
            termsOfUse: termsOfUse
        )

        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            paymentConsentOptions: consentOptions,
            returnURL: AWXThreeDSReturnURL
        )

        XCTAssertNoThrow(try session.validate())
    }

    func testIsExpressCheckout() {
        // Test with payment intent provider - should be express checkout
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let sessionWithProvider = Session(
            paymentIntentProvider: provider,
            countryCode: "AU",
            returnURL: AWXThreeDSReturnURL
        )

        XCTAssertTrue(sessionWithProvider.isExpressCheckout)

        // Test with payment intent - should not be express checkout
        let sessionWithIntent = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            returnURL: AWXThreeDSReturnURL
        )

        XCTAssertFalse(sessionWithIntent.isExpressCheckout)

        // Test with legacy session - should not be express checkout
        let legacySession = AWXOneOffSession()
        legacySession.paymentIntent = mockPaymentIntent
        legacySession.countryCode = "AU"

        XCTAssertFalse(legacySession.isExpressCheckout)
    }
}
