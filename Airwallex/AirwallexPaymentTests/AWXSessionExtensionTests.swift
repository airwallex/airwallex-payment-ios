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
            returnURL: AWXThreeDSReturnURL,
            paymentConsentOptions: .init(nextTriggeredBy: .customerType)
        )
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateSessionRecurringWithoutCustomerID() {
        mockPaymentIntent.customerId = nil
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            returnURL: AWXThreeDSReturnURL,
            paymentConsentOptions: .init(nextTriggeredBy: .customerType)
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
}
