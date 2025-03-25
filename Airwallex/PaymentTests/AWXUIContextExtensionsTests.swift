//
//  AWXUIContextExtensionsTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import UIKit
import Core
@testable import Payment
import XCTest

class AWXUIContextExtensionsTests: XCTestCase {
    
    private var mockOneoffSession: AWXOneOffSession!
    private var mockViewController: MockPaymentResultDelegate!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    private var mockPaymentIntent: AWXPaymentIntent!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockOneoffSession = AWXOneOffSession()
        mockPaymentIntent = AWXPaymentIntent()
        mockViewController = MockPaymentResultDelegate()
        
        mockOneoffSession.paymentIntent = mockPaymentIntent
        mockPaymentIntent.customerId = mockCustomerId
        mockPaymentIntent.clientSecret = mockClientSecret
        mockPaymentIntent.id = mockIntentId
        
        AWXAPIClientConfiguration.shared().clientSecret = mockClientSecret
    }
    
    override class func tearDown() {
        super.tearDown()
        AWXAPIClientConfiguration.shared().clientSecret = nil
    }
    
    @MainActor func testLaunchPaymentViewHierarchyAssertion() {
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: mockOneoffSession,
                style: .push
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidViewHierarchy = error else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidViewHierarchy, but get \(error)")
                return
            }
        }
    }
    
    @MainActor func testLaunchPaymentPaymentIntentAssertion() {
        mockOneoffSession.paymentIntent = nil
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: mockOneoffSession,
                style: .push
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
                  case AWXSession.ValidationError.invalidPaymentIntent(_) = underlyingError else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidPaymentIntent, but get \(error)")
                return
            }
        }
        
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: AWXRecurringWithIntentSession(),
                style: .push
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
                  case AWXSession.ValidationError.invalidPaymentIntent(_) = underlyingError else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidPaymentIntent, but get \(error)")
                return
            }
        }
    }
    
    @MainActor func testLaunchPaymentCustomerIdAssertion() {
        // check recurring session
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: AWXRecurringSession(),
                style: .push
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
                  case AWXSession.ValidationError.invalidCustomerId(_) = underlyingError else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidCustomerId, but get \(error)")
                return
            }
        }
        // check recurring with intent session
        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        mockPaymentIntent.customerId = nil
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: recurringWithIntentSession,
                style: .push
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
                  case AWXSession.ValidationError.invalidCustomerId(_) = underlyingError else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidCustomerId, but get \(error)")
                return
            }
        }
    }
    
    @MainActor func testLaunchPaymentClientSecretAssertion() {
        AWXAPIClientConfiguration.shared().clientSecret = nil
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: mockOneoffSession,
                style: .push
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidClientSecret = error else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidClientSecret, but get \(error)")
                return
            }
        }
    }
    
    @MainActor func testLaunchPaymentInvalidCardBrandAssertion() {
        XCTAssertThrowsError(
            try AWXUIContext.launchCardPayment(
                from: mockViewController,
                session: mockOneoffSession,
                supportedBrands: [],
                style: .present
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidCardBrand = error else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidCardBrand, but get \(error)")
                return
            }
        }
    }
    
    @MainActor func testLaunchPaymentInvalidMethodFilterAssertion() {
        XCTAssertThrowsError(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: mockOneoffSession,
                filterBy: [],
                style: .present
            )
        ) { error in
            guard case AWXUIContext.LaunchError.invalidMethodFilter = error else {
                XCTFail("Expected AWXUIContext.LaunchError.invalidMethodFilter, but get \(error)")
                return
            }
        }
    }
    
    @MainActor func testLaunchPayment() {
        XCTAssertNoThrow(
            try AWXUIContext.launchPayment(
                from: mockViewController,
                session: mockOneoffSession,
                filterBy: [AWXApplePayKey],
                style: .present
            )
        )
        XCTAssert(AWXUIContext.shared().delegate === mockViewController)
        XCTAssert(AWXUIContext.shared().session === mockOneoffSession)
        XCTAssertTrue(mockOneoffSession.hidePaymentConsents)
        XCTAssert(mockOneoffSession.paymentMethods?.count == 1 && mockOneoffSession.paymentMethods?.first == AWXApplePayKey)
    }
    
    @MainActor func testLaunchCardPayment() {
        XCTAssertNoThrow(
            try AWXUIContext.launchCardPayment(
                from: mockViewController,
                session: mockOneoffSession,
                style: .present
            )
        )
        XCTAssert(AWXUIContext.shared().delegate === mockViewController)
        XCTAssert(AWXUIContext.shared().session === mockOneoffSession)
        XCTAssertNil(mockOneoffSession.paymentMethods)
        XCTAssertFalse(mockOneoffSession.hidePaymentConsents)
    }
}
