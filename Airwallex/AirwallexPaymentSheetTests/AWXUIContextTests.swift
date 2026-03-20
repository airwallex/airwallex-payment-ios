//
//  AWXUIContextTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import Foundation
import UIKit
import XCTest

@MainActor class AWXUIContextTests: XCTestCase {
    
    private var mockOneoffSession: AWXOneOffSession!
    private var mockViewController: MockPaymentResultDelegate!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    private var mockPaymentIntent: AWXPaymentIntent!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockOneoffSession = AWXOneOffSession()
        mockOneoffSession.countryCode = "AU"
        mockPaymentIntent = AWXPaymentIntent()
        mockViewController = MockPaymentResultDelegate()
        
        mockOneoffSession.paymentIntent = mockPaymentIntent
        mockPaymentIntent.customerId = mockCustomerId
        mockPaymentIntent.clientSecret = mockClientSecret
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.currency = "AUD"
        mockPaymentIntent.amount = NSDecimalNumber(value: 1)
        
        AWXAPIClientConfiguration.shared().clientSecret = mockClientSecret
    }
    
    override class func tearDown() {
        super.tearDown()
        AWXAPIClientConfiguration.shared().clientSecret = nil
    }
    
    func testLaunchPaymentViewHierarchyAssertion() {
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            launchStyle: .push
        )
        
        guard let error = mockViewController.error,
              case AWXUIContext.LaunchError.invalidViewHierarchy = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidViewHierarchy, but get \(String(describing: mockViewController.error))")
            return
        }
    }
    
    func testLaunchPaymentPaymentIntentAssertionOneOffSession() {
        mockOneoffSession.paymentIntent = nil
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            launchStyle: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidData(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidPaymentIntent, but get \(error)")
            return
        }
    }
    
    func testLaunchPaymentPaymentIntentAssertionRecurringWithIntentSession() {
        let session = AWXRecurringWithIntentSession()
        session.countryCode = "AUD"
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: session,
            launchStyle: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidData(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidPaymentIntent, but get \(error)")
            return
        }
    }
    
    func testLaunchPaymentCustomerIdAssertionRecurringSession() {
        let session = AWXRecurringWithIntentSession()
        session.countryCode = "AUD"
        // check recurring session
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: session,
            launchStyle: .push
        )
        
        guard let error = mockViewController.error else {
            XCTFail("error not validated")
            return
        }
        
        guard case AWXUIContext.LaunchError.invalidSession(underlyingError: let underlyingError) = error,
              case AWXSession.ValidationError.invalidData(_) = underlyingError else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidCustomerId, but get \(error)")
            return
        }
    }
    
    func testLaunchPaymentCustomerIdAssertionRecurringWithIntentSession() {
        // check recurring with intent session
        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        mockPaymentIntent.customerId = nil
        recurringWithIntentSession.countryCode = "AU"
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: recurringWithIntentSession,
            launchStyle: .push
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
    
    func testLaunchPaymentClientSecretAssertion() {
        AWXAPIClientConfiguration.shared().clientSecret = nil
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            launchStyle: .push
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
    
    func testLaunchPaymentInvalidCardBrandAssertion() {
        AWXUIContext.launchCardPayment(
            from: mockViewController,
            session: mockOneoffSession,
            supportedBrands: [],
            launchStyle: .present
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
    
    func testLaunchPaymentInvalidMethodFilterAssertion() {
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            filterBy: [],
            launchStyle: .present
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
    
    func testLaunchPayment() {
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            filterBy: [AWXApplePayKey],
            launchStyle: .present
        )
        
        guard mockViewController.error == nil else {
            XCTFail("unexpected error: \(mockViewController.error!)")
            return
        }

        XCTAssert(mockOneoffSession.paymentMethods?.count == 1 && mockOneoffSession.paymentMethods?.first == AWXApplePayKey)
    }
    
    func testLaunchCardPayment() {
        AWXUIContext.launchCardPayment(
            from: mockViewController,
            session: mockOneoffSession,
            launchStyle: .present
        )
        
        guard mockViewController.error == nil else {
            XCTFail("unexpected error: \(mockViewController.error!)")
            return
        }
        
        XCTAssertNil(mockOneoffSession.paymentMethods)
        XCTAssertFalse(mockOneoffSession.hidePaymentConsents)
    }
    
    // MARK: - Configuration-based API Tests
    
    func testLaunchWithDefaultConfiguration() {
        let configuration = AWXUIContext.Configuration()
        configuration.launchStyle = .present
        
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            configuration: configuration
        )
        
        XCTAssertNil(mockViewController.error, "unexpected error: \(String(describing: mockViewController.error))")
    }
    
    func testLaunchWithComponentCardEmptyBrands() {
        let configuration = AWXUIContext.Configuration()
        configuration.elementType = .component
        configuration.paymentMethodName = AWXCardKey
        configuration.supportedCardBrands = []
        configuration.launchStyle = .present
        
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            configuration: configuration
        )
        
        guard let error = mockViewController.error,
              case AWXUIContext.LaunchError.invalidCardBrand = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidCardBrand, but got \(String(describing: mockViewController.error))")
            return
        }
    }
    
    func testLaunchWithComponentCardInvalidBrands() {
        let configuration = AWXUIContext.Configuration()
        configuration.elementType = .component
        configuration.paymentMethodName = AWXCardKey
        configuration.supportedCardBrands = [AWXCardBrand(rawValue: "invalid_brand")]
        configuration.launchStyle = .present
        
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            configuration: configuration
        )
        
        guard let error = mockViewController.error,
              case AWXUIContext.LaunchError.invalidCardBrand = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidCardBrand, but got \(String(describing: mockViewController.error))")
            return
        }
    }
    
    func testLaunchWithComponentNilNameFallsBackToPaymentSheet() {
        let configuration = AWXUIContext.Configuration()
        configuration.elementType = .component
        configuration.paymentMethodName = nil
        configuration.launchStyle = .present
        
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            configuration: configuration
        )
        
        XCTAssertNil(mockViewController.error, "unexpected error: \(String(describing: mockViewController.error))")
    }
    
    func testLaunchWithPushStyleWithoutNavController() {
        let configuration = AWXUIContext.Configuration()
        configuration.launchStyle = .push
        
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            configuration: configuration
        )
        
        guard let error = mockViewController.error,
              case AWXUIContext.LaunchError.invalidViewHierarchy = error else {
            XCTFail("Expected AWXUIContext.LaunchError.invalidViewHierarchy, but got \(String(describing: mockViewController.error))")
            return
        }
    }
    
    func testLaunchWithComponentNonCardMethod() {
        let configuration = AWXUIContext.Configuration()
        configuration.elementType = .component
        configuration.paymentMethodName = AWXApplePayKey
        configuration.launchStyle = .present
        
        AWXUIContext.launchPayment(
            from: mockViewController,
            session: mockOneoffSession,
            configuration: configuration
        )
        
        XCTAssertNil(mockViewController.error, "unexpected error: \(String(describing: mockViewController.error))")
    }
}
