//
//  PaymentSessionHandlerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Core
import UIKit
import XCTest
import ApplePay
import Card
import Redirect

@testable import Payment

class PaymentSessionHandlerTests: XCTestCase {

    private var mockPaymentResultDelegate: MockPaymentResultDelegate!
    private var mockSession: AWXOneOffSession!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    private var mockPaymentIntent: AWXPaymentIntent!
    
    private var mockMethodType: AWXPaymentMethodType!
    private var mockSessionHandler: PaymentSessionHandler!
    private var mockProvider: AWXDefaultProvider!
    

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockPaymentResultDelegate = MockPaymentResultDelegate()
        mockSession = AWXOneOffSession()
        mockMethodType = AWXPaymentMethodType()
        mockMethodType.name = AWXCardKey
        
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.clientSecret = mockClientSecret
        mockSession.paymentIntent = mockPaymentIntent
        
        AWXAPIClientConfiguration.shared().clientSecret = mockClientSecret
        
        mockProvider = AWXDefaultProvider(delegate: MockProviderDelegate(), session: mockSession)
        mockSessionHandler = try PaymentSessionHandler(
            session: mockSession,
            viewController: mockPaymentResultDelegate,
            methodType: mockMethodType
        )
    }
    
    override class func tearDown() {
        super.tearDown()
        AWXAPIClientConfiguration.shared().clientSecret = nil
    }

    func testInit() throws {
        let test = {
            let viewController = UIViewController()
            let handler = try PaymentSessionHandler(
                session: self.mockSession,
                viewController: viewController,
                paymentResultDelegate: self.mockPaymentResultDelegate,
                methodType: self.mockMethodType
            )
            XCTAssertTrue(handler.paymentResultDelegate === self.mockPaymentResultDelegate)
            XCTAssertFalse(handler.viewController === self.mockPaymentResultDelegate)
            XCTAssertTrue(handler.viewController === viewController)
            XCTAssertEqual(handler.methodType, self.mockMethodType)
            XCTAssertEqual(handler.session, self.mockSession)
        }
        XCTAssertNoThrow(try test())
    }

    func testConvenienceInit() {
        let test = {
            let handler = try PaymentSessionHandler(
                session: self.mockSession,
                viewController: self.mockPaymentResultDelegate
            )
            XCTAssertTrue(handler.paymentResultDelegate === self.mockPaymentResultDelegate)
            XCTAssertTrue(handler.viewController === self.mockPaymentResultDelegate)
            XCTAssertNil(handler.methodType)
            XCTAssertTrue(handler.session === self.mockSession)
        }
        XCTAssertNoThrow(try test())
    }
    
    func testInitAssertions() {
        let test1 = {
            let _ = try PaymentSessionHandler(
                session: AWXSession(),
                viewController: self.mockPaymentResultDelegate
            )
        }
        XCTAssertThrowsError(try test1()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidSession(underlyingError: error) = error,
                  case AWXSession.ValidationError.invalidSessionType(_) = error else {
                XCTFail("Expected AWXSession.ValidationError.invalidSessionType but got \(error)")
                return
            }
        }
        let test2 = {
            self.mockSession.paymentIntent = nil
            let _ = try PaymentSessionHandler(
                session: self.mockSession,
                viewController: self.mockPaymentResultDelegate
            )
        }
        XCTAssertThrowsError(try test2()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidSession(underlyingError: error) = error,
                  case AWXSession.ValidationError.invalidPaymentIntent(_) = error else {
                XCTFail("Expected AWXSession.ValidationError.invalidPaymentIntent but got \(error)")
                return
            }
        }
        let test3 = {
            let recurringSession = AWXRecurringSession()
            let _ = try PaymentSessionHandler(
                session: recurringSession,
                viewController: self.mockPaymentResultDelegate
            )
        }
        XCTAssertThrowsError(try test3()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidSession(underlyingError: error) = error,
                  case AWXSession.ValidationError.invalidCustomerId(_) = error else {
                XCTFail("Expected AWXSession.ValidationError.invalidCustomerId but got \(error)")
                return
            }
        }
    }

    // test start apple pay check if it throws as expected
    func testStartApplePay() {
        XCTAssertThrowsError(try mockSessionHandler.startApplePay()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXApplePayProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.InvalidMethodType but got \(error)")
                return
            }
        }
        
        mockMethodType.name = AWXApplePayKey
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant_id")
        XCTAssertNoThrow(try mockSessionHandler.startApplePay())
        
        mockSession.applePayOptions = nil
        XCTAssertThrowsError(try mockSessionHandler.startApplePay()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXApplePayProvider.ValidationError.invalidApplePayOptions(_) = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions but got \(error)")
                return
            }
        }
        
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "")
        XCTAssertThrowsError(try mockSessionHandler.startApplePay()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXApplePayProvider.ValidationError.invalidApplePayOptions = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions but got \(error)")
                return
            }
        }
        
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant_id")
        mockSession.applePayOptions?.supportedNetworks = [PKPaymentNetwork.eftpos]
        XCTAssertThrowsError(try mockSessionHandler.startApplePay()) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXApplePayProvider.ValidationError.invalidApplePayOptions = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions but got \(error)")
                return
            }
        }
    }

    // test startCardPayment similar to testStartApplePay
    func testStartCardPayment() {
        let card = AWXCard(name: "", cardNumber: "123", expiry: "1233", cvc: "333")

        // test invalid method type
        mockMethodType.name = AWXApplePayKey
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidMethodType but got \(error)")
                return
            }
        }
        // test empty card scheme
        mockMethodType.name = AWXCardKey
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidCardSchemes = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardSchemes but got \(error)")
                return
            }
        }
        // test invalid card scheme with "unknown"
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable + [AWXCardScheme(name: "unknown")]
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidCardSchemes = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardSchemes but got \(error)")
                return
            }
        }
        // test invalid card number
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidCardInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo but got \(error)")
                return
            }
        }
        // test invalid card holder name
        card.number = "4111111111111111"
        mockSession.requiredBillingContactFields = [.name]
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidCardInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo but got \(error)")
                return
            }
        }
        // test no billing info
        card.name = "John Citizen"
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardBilling but got \(error)")
                return
            }
        }
        // test invalid name in billing info
        let billing = AWXPlaceDetails()
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardBilling but got \(error)")
                return
            }
        }
        // test invalid address in billing info
        mockSession.requiredBillingContactFields = [.name, .address]
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardBilling but got \(error)")
                return
            }
        }

        // Test for invalid state
        billing.address = AWXAddress()
        billing.address?.countryCode = "US"
        billing.address?.state = ""
        billing.address?.city = "New York"
        billing.address?.street = "123 Main St"
        billing.address?.postcode = "12345"
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }

        // Test for invalid city
        billing.address?.state = "NY"
        billing.address?.city = ""
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }

        // Test for invalid country code
        billing.address?.city = "New York"
        billing.address?.countryCode = "INVALID"
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }

        // Test for invalid street
        billing.address?.street = ""
        billing.address?.countryCode = "US"
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }

        // Test for invalid postal code
        billing.address?.street = "123 Main St"
        billing.address?.postcode = ""
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }

        // Test for invalid phone number
        billing.address?.postcode = "12345"
        billing.address?.countryCode = "US"
        billing.phoneNumber = "INVALID"
        mockSession.requiredBillingContactFields = [.name, .address, .phone]
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }

        // Test for invalid email
        billing.phoneNumber = "+1234567890"
        billing.email = "invalid-email"
        mockSession.requiredBillingContactFields = [.name, .address, .phone, .email]
        XCTAssertThrowsError(try mockSessionHandler.startCardPayment(with: card, billing: billing)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(error)")
                return
            }
        }
    }

    func testStartConsentPayment() {
        let consent = AWXPaymentConsent()
        // Test for invalid consent
        consent.id = ""
        XCTAssertThrowsError(try mockSessionHandler.startConsentPayment(with: consent)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidConsent = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent but got \(error)")
                return
            }
        }
        
        // Test for invalid method Type
        consent.id = "cst_123"
        mockMethodType.name = "invalid"
        XCTAssertThrowsError(try mockSessionHandler.startConsentPayment(with: consent)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent but got \(error)")
                return
            }
        }
    }

    func testStartConsentPaymentWithId() {
        // Test for invalid consent ID
        var consentId = "invalid_id"
        XCTAssertThrowsError(try mockSessionHandler.startConsentPayment(withId: consentId)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidConsent = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent but got \(error)")
                return
            }
        }
        
        // Test for invalid method Type
        consentId = "cst_123"
        mockMethodType.name = "invalid"
        XCTAssertThrowsError(try mockSessionHandler.startConsentPayment(withId: consentId)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXCardProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent but got \(error)")
                return
            }
        }
    }

    func testStartRedirectPayment() {
        // Test for invalid method type
        XCTAssertThrowsError(try mockSessionHandler.startRedirectPayment(with: AWXCardKey, additionalInfo: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXRedirectActionProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType but got \(error)")
                return
            }
        }
        mockMethodType.name = AWXApplePayKey
        XCTAssertThrowsError(try mockSessionHandler.startRedirectPayment(with: AWXCardKey, additionalInfo: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXRedirectActionProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType but got \(error)")
                return
            }
        }
        mockMethodType.name = AWXApplePayKey
        XCTAssertThrowsError(try mockSessionHandler.startRedirectPayment(with: AWXApplePayKey, additionalInfo: nil)) { error in
            guard case let PaymentSessionHandler.HandlerError.invalidPayment(underlyingError: error) = error,
                  case AWXRedirectActionProvider.ValidationError.invalidMethodType = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType but got \(error)")
                return
            }
        }
    }
    
    // add test cases for AWXProviderDelegate
    func testProviderDidStartRequest() {
        mockSessionHandler.providerDidStartRequest(mockProvider)
        XCTAssert(mockPaymentResultDelegate.isLoading)
    }

    func testProviderDidEndRequest() {
        mockSessionHandler.providerDidEndRequest(mockProvider)
        XCTAssert(!mockPaymentResultDelegate.isLoading)
    }

    func testProviderDidInitializePaymentIntentId() {
        let mockIntentId = "mock_intent_id"
        let session = AWXRecurringSession()
        XCTAssertNoThrow {
            let handler = try PaymentSessionHandler(session: session, viewController: self.mockPaymentResultDelegate)
            handler.provider(self.mockProvider, didInitializePaymentIntentId: mockIntentId)
            XCTAssertEqual(session.paymentIntentId(), mockIntentId)
        }
    }

    func testProviderDidCompleteWithPaymentConsentId() {
        let paymentConsentId = "cst_123"
        mockSessionHandler.provider(mockProvider, didCompleteWithPaymentConsentId: paymentConsentId)
        XCTAssertEqual(mockPaymentResultDelegate.consentId, paymentConsentId)
    }

    func testProviderDidCompleteWithStatus() {
        let allCases: [AirwallexPaymentStatus] = [.notStarted, .cancel, .failure, .inProgress, .success]
        for status in allCases {
            mockSessionHandler.provider(mockProvider, didCompleteWith: status, error: nil)
            XCTAssertEqual(mockPaymentResultDelegate.status, status)
        }
    }

    func testProviderShouldHandleNextAction() {
        let nextAction = AWXConfirmPaymentNextAction()
        mockSessionHandler.provider(mockProvider, shouldHandle: nextAction)
        XCTAssertEqual(mockPaymentResultDelegate.status, .failure)
    }

    func testProviderShouldInsertController() {
        let controller = UIViewController()
        mockSessionHandler.provider(mockProvider, shouldInsert: controller)
        XCTAssertEqual(mockSessionHandler.hostViewController(), mockPaymentResultDelegate)
        XCTAssertTrue(mockPaymentResultDelegate.children.contains(controller))
    }

    func testProviderShouldPresentController() {
        let controller = UIViewController()
        mockSessionHandler.provider(mockProvider, shouldPresent: controller, forceToDismiss: false, withAnimation: false)
        XCTAssertEqual(mockSessionHandler.hostViewController(), mockPaymentResultDelegate)
        XCTAssertEqual(mockPaymentResultDelegate.presentedViewControllerSpy, controller)
    }
}
