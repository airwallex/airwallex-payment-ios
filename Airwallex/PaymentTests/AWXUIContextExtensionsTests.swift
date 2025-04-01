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
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            style: .push
        )
        
        guard let error = mockViewController.error,
              case AWXUIContext.LaunchError.invalidViewHierarchy = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidViewHierarchy, but get \(String(describing: mockViewController.error))")
            return
        }
    }
    
    @MainActor func testLaunchPaymentPaymentIntentAssertionOneOffSession() {
        mockOneoffSession.paymentIntent = nil
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            style: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidPaymentIntent(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidPaymentIntent, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPaymentPaymentIntentAssertionRecurringWithIntentSession() {
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: AWXRecurringWithIntentSession(),
            style: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidPaymentIntent(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidPaymentIntent, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPaymentCustomerIdAssertionRecurringSession() {
        // check recurring session
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: AWXRecurringSession(),
            style: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidCustomerId(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidCustomerId, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPaymentCustomerIdAssertionRecurringWithIntentSession() {
        // check recurring with intent session
        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        mockPaymentIntent.customerId = nil
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: recurringWithIntentSession,
            style: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidCustomerId(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidCustomerId, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPaymentClientSecretAssertion() {
        AWXAPIClientConfiguration.shared().clientSecret = nil
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            style: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidClientSecret = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidClientSecret, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPaymentInvalidCardBrandAssertion() {
        AWXUIContext.launchCardPayment(
            from: mockViewController,
            session: mockOneoffSession,
            supportedBrands: [],
            style: .present
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidCardBrand = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidCardBrand, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPaymentInvalidMethodFilterAssertion() {
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            filterBy: [],
            style: .present
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidMethodFilter = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidMethodFilter, but get \(error)")
            return
        }
    }
    
    @MainActor func testLaunchPayment() {
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            filterBy: [AWXApplePayKey],
            style: .present
        )
        
        guard mockViewController.error == nil else {
            XCTFail("unexpected error: \(mockViewController.error!)")
            return
        }
        
        XCTAssert(AWXUIContext.shared().delegate === mockViewController)
        XCTAssert(AWXUIContext.shared().session === mockOneoffSession)
        XCTAssertTrue(mockOneoffSession.hidePaymentConsents)
        XCTAssert(mockOneoffSession.paymentMethods?.count == 1 && mockOneoffSession.paymentMethods?.first == AWXApplePayKey)
    }
    
    @MainActor func testLaunchCardPayment() {
        AWXUIContext.launchCardPayment(
            from: mockViewController,
            session: mockOneoffSession,
            style: .present
        )
        
        guard mockViewController.error == nil else {
            XCTFail("unexpected error: \(mockViewController.error!)")
            return
        }
        
        XCTAssert(AWXUIContext.shared().delegate === mockViewController)
        XCTAssert(AWXUIContext.shared().session === mockOneoffSession)
        XCTAssertNil(mockOneoffSession.paymentMethods)
        XCTAssertFalse(mockOneoffSession.hidePaymentConsents)
    }
}
