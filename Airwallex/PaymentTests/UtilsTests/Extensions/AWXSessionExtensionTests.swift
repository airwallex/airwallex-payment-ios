//
//  AWXSessionExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment
import Core

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
        
        AWXAPIClientConfiguration.shared().clientSecret = mockClientSecret
    }
    
    func testValidateOneOffSession() {
        let session = AWXOneOffSession()
        session.paymentIntent = mockPaymentIntent
        
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateOneOffSessionWithoutPaymentIntent() {
        let session = AWXOneOffSession()
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidPaymentIntent(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringWithIntentSession() {
        let session = AWXRecurringWithIntentSession()
        session.paymentIntent = mockPaymentIntent
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateRecurringWithIntentSessionWithoutCustomerId() {
        let session = AWXRecurringWithIntentSession()
        session.paymentIntent = mockPaymentIntent
        mockPaymentIntent.customerId = nil
        
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidCustomerId(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
    }
    
    func testValidateRecurringSession() {
        let session = AWXRecurringSession()
        session.setCustomerId(mockCustomerId)
        
        XCTAssertNoThrow(try session.validate())
    }
    
    func testValidateRecurringSessionWithoutCustomerId() {
        let session = AWXRecurringSession()
        XCTAssertThrowsError(try session.validate()) { error in
            guard case AWXSession.ValidationError.invalidCustomerId(_) = error else {
                XCTFail(error.localizedDescription)
                return
            }
        }
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
