//
//  PaymentSessionHandlerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment

class PaymentSessionHandlerTests: XCTestCase {

    private var mockPaymentResultDelegate: MockPaymentResultDelegate!
    private var mockSession: AWXOneOffSession!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockAddress: AWXAddress!
    
    private var mockMethodType: AWXPaymentMethodType!
    private var mockSessionHandler: PaymentSessionHandler!
    private var mockProvider: AWXDefaultProvider!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockPaymentResultDelegate = MockPaymentResultDelegate()
        mockSession = AWXOneOffSession()
        mockSession.countryCode = "AU"
        mockMethodType = AWXPaymentMethodType()
        mockMethodType.name = AWXCardKey
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.clientSecret = mockClientSecret
        mockPaymentIntent.amount = NSDecimalNumber(value: 1)
        mockPaymentIntent.currency = "AUD"
        mockSession.paymentIntent = mockPaymentIntent

        mockAddress = AWXAddress()
        mockAddress.countryCode = "AU"
        mockAddress.state = "NSW"
        mockAddress.city = "Sydney"
        mockAddress.street = "123 Main St"
        mockAddress.postcode = "2000"
        
        AWXAPIClientConfiguration.shared().clientSecret = mockClientSecret
        
        mockProvider = AWXDefaultProvider(delegate: MockProviderDelegate(), session: mockSession)
        mockSessionHandler = PaymentSessionHandler(
            session: mockSession,
            viewController: mockPaymentResultDelegate,
            methodType: mockMethodType
        )
    }
    
    override class func tearDown() {
        super.tearDown()
        AWXAPIClientConfiguration.shared().clientSecret = nil
    }

    func testInit() {
        let viewController = UIViewController()
        let handler = PaymentSessionHandler(
            session: mockSession,
            viewController: viewController,
            paymentResultDelegate: mockPaymentResultDelegate,
            methodType: mockMethodType) { _ in }
        XCTAssertTrue(handler.paymentResultDelegate === mockPaymentResultDelegate)
        XCTAssertFalse(handler.viewController === mockPaymentResultDelegate)
        XCTAssertTrue(handler.viewController === viewController)
        XCTAssertEqual(handler.methodType, mockMethodType)
        XCTAssertEqual(handler.session, mockSession)
        XCTAssertNotNil(handler.dismissAction)
        XCTAssertTrue(AnalyticsLogger.shared().session === mockSession)
    }

    func testConvenienceInit() {
        let handler = PaymentSessionHandler(
            session: self.mockSession,
            viewController: self.mockPaymentResultDelegate
        )
        XCTAssertTrue(handler.paymentResultDelegate === self.mockPaymentResultDelegate)
        XCTAssertTrue(handler.viewController === self.mockPaymentResultDelegate)
        XCTAssertNil(handler.methodType)
        XCTAssertTrue(handler.session === self.mockSession)
        XCTAssertNil(mockPaymentResultDelegate.error)
        XCTAssertNil(handler.dismissAction)
        XCTAssertTrue(AnalyticsLogger.shared().session === mockSession)
    }
    
    func testConvenienceInit2() {
        let viewController = UIViewController()
        let handler = PaymentSessionHandler(
            session: mockSession,
            viewController: viewController,
            paymentResultDelegate: mockPaymentResultDelegate
        )
        XCTAssertTrue(handler.paymentResultDelegate === self.mockPaymentResultDelegate)
        XCTAssertTrue(handler.viewController === viewController)
        XCTAssertNil(handler.methodType)
        XCTAssertTrue(handler.session === self.mockSession)
        XCTAssertNil(mockPaymentResultDelegate.error)
        XCTAssertNil(handler.dismissAction)
        XCTAssertTrue(AnalyticsLogger.shared().session === mockSession)
    }
    
    // test start apple pay check if it throws as expected
    func testStartApplePayInvalidMethodType() {
        mockSessionHandler.startApplePay()
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXApplePayProvider.ValidationError.invalidMethodType = error else {
            XCTFail("Expected AWXApplePayProvider.ValidationError.InvalidMethodType but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartApplePayNilApplePayOptions() {
        mockMethodType.name = AWXApplePayKey
        mockSession.applePayOptions = nil
        mockSessionHandler.startApplePay()
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXApplePayProvider.ValidationError.invalidApplePayOptions(_) = error else {
            XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartApplePayWithInvalidMerchantID() {
        mockMethodType.name = AWXApplePayKey
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "")
        mockSessionHandler.startApplePay()
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXApplePayProvider.ValidationError.invalidApplePayOptions = error else {
            XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartApplePayWithInvalidPaymentNetwork() {
        mockMethodType.name = AWXApplePayKey
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant_id")
        mockSession.applePayOptions?.supportedNetworks = [PKPaymentNetwork.eftpos]
        mockSessionHandler.startApplePay()
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXApplePayProvider.ValidationError.invalidApplePayOptions = error else {
            XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    // test startCardPayment similar to testStartApplePay
    func testStartCardPaymentWithInvalidPaymentMethod() {
        let card = AWXCard(name: "", cardNumber: "123", expiryMonth: "12", expiryYear: "33", cvc: "333")
        
        // test invalid method type
        mockMethodType.name = AWXApplePayKey
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidMethodType = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidMethodType but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithEmptyCardScheme() {
        // test empty card scheme
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockMethodType.name = AWXCardKey
        mockMethodType.cardSchemes = []
        
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardSchemes = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardSchemes but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithUnknownCardScheme() {
        // test invalid card scheme with "unknown"
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockMethodType.name = AWXCardKey
        mockMethodType.cardSchemes = [AWXCardScheme(name: "unknown")]
        
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardSchemes = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardSchemes but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithInvalidCardNumber() {
        // Test for invalid card number
        let card = AWXCard(name: "John Doe", cardNumber: "123", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithInvalidExpiry() {
        // Test for invalid expiry date
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "00", cvc: "123")
        mockMethodType.name = AWXCardKey
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo")
            return
        }
        
        card.expiryMonth = "13"
        mockPaymentResultDelegate.error = nil
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo")
            return
        }
        
    }

    func testStartCardPaymentWithInvalidCVC() {
        // Test for invalid CVC
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "")
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
        
        card.cvc = "999999"
        mockPaymentResultDelegate.error = nil
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithInvalidName() {
        // Test for invalid name
        let card = AWXCard(name: "", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidCardInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartCardPaymentWithNoBillingInfo() {
        // Test for missing billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        
        mockSessionHandler.startCardPayment(with: card, billing: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithInvalidNameInBillingInfo() {
        // Test for invalid name in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        let billing = AWXPlaceDetails()
        billing.firstName = ""
        billing.lastName = ""
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithAddressRequiredInBillingInfo() {
        // Test for missing address in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        billing.address = nil
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }   
    }

    func testStartCardPaymentWithNoStateInBillingInfo() {
        // Test for missing state in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        mockAddress.state = nil
        billing.address = mockAddress
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartCardPaymentWithNoCountryInBillingInfo() {
        // Test for missing country in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        mockAddress.countryCode = nil
        billing.address = mockAddress
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithNoStreetInBillingInfo() {
        // Test for missing street in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        mockAddress.street = nil
        billing.address = mockAddress
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithNoPostcodeInBillingInfo() {
        // Test for missing postcode in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        mockAddress.postcode = nil
        billing.address = mockAddress
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithNoPhoneNumberInBillingInfo() {
        // Test for missing phone number in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address, .phone]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        billing.phoneNumber = nil
        billing.address = mockAddress
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartCardPaymentWithNoEmailInBillingInfo() {
        // Test for missing email in billing information
        let card = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "33", cvc: "123")
        mockSession.requiredBillingContactFields = [.name, .address, .email]
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        billing.email = nil
        billing.address = mockAddress
        
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidBillingInfo = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartConsentPaymentWithInvalidConsent() {
        let consent = AWXPaymentConsent()
        // Test for invalid consent
        consent.id = ""
        mockSessionHandler.startConsentPayment(with: consent)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidConsent = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartConsentPaymentWithInvalidMethodType() {
        // Test for invalid method type
        let consent = AWXPaymentConsent()
        consent.id = "cst_123"
        mockMethodType.name = AWXApplePayKey
        mockSessionHandler.startConsentPayment(with: consent)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidMethodType = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidMethodType but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartConsentPaymentWithInvalidID() {
        // Test for invalid consent ID
        mockSessionHandler.startConsentPayment(withId: "")
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXCardProvider.ValidationError.invalidConsent = error else {
            XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }

    func testStartRedirectPaymentWithCardPayment() {
        // Test for invalid method type
        mockMethodType.name = AWXCardKey
        mockSessionHandler.startRedirectPayment(with: AWXCardKey, additionalInfo: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXRedirectActionProvider.ValidationError.invalidMethodType = error else {
            XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartRedirctPaymentWithApplePay() {
        mockMethodType.name = AWXApplePayKey
        mockSessionHandler.startRedirectPayment(with: AWXApplePayKey, additionalInfo: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXRedirectActionProvider.ValidationError.invalidMethodType = error else {
            XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType but got \(String(describing: mockPaymentResultDelegate.error))")
            return
        }
    }
    
    func testStartRedirectPaymentWithWrongPaymentMethod() {
        mockMethodType.name = "paypal"
        mockSessionHandler.startRedirectPayment(with: "wechatpay", additionalInfo: nil)
        guard let error = mockPaymentResultDelegate.error,
              case let PaymentSessionHandler.ValidationError.invalidPayment(underlyingError: error) = error,
              case AWXRedirectActionProvider.ValidationError.invalidMethodType = error else {
            XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType but got \(String(describing: mockPaymentResultDelegate.error))")
            return
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
            let handler = PaymentSessionHandler(session: session, viewController: self.mockPaymentResultDelegate)
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
        let allCases: [AirwallexPaymentStatus] = [.cancel, .failure, .inProgress, .success]
        for status in allCases {
            mockSessionHandler.provider(mockProvider, didCompleteWith: status, error: nil)
            XCTAssertEqual(mockPaymentResultDelegate.status, status)
        }
        for status in allCases {
            mockSessionHandler.dismissAction = { $0() }
            mockSessionHandler.provider(mockProvider, didCompleteWith: status, error: nil)
            XCTAssertEqual(mockPaymentResultDelegate.status, status)
        }
    }
    
    func testProviderDidCompleteWithApplePayInProgress() {
        mockSessionHandler.dismissAction = { $0() }
        mockMethodType.name = AWXApplePayKey
        mockSessionHandler.provider(mockProvider, didCompleteWith: .inProgress, error: nil)
        XCTAssertNil(mockPaymentResultDelegate.status)
    }

    func testProviderShouldHandleNextAction() {
        let nextAction = AWXConfirmPaymentNextAction()
        mockSessionHandler.provider(mockProvider, shouldHandle: nextAction)
        XCTAssertEqual(mockPaymentResultDelegate.status, .failure)
    }

    func testProviderHandleNotExistingCallSDKAction() {
        let nextAction = AWXConfirmPaymentNextAction.decode(fromJSON: ["type" : "call_sdk"]) as! AWXConfirmPaymentNextAction
        mockSessionHandler.provider(mockProvider, shouldHandle: nextAction)
        XCTAssertEqual(mockPaymentResultDelegate.status, .failure)
    }

    func testProviderShouldHandleNextActionWithConsent() {
        let mockConsent = AWXPaymentConsent()
        mockConsent.id = "mock_cst_id"
        let nextAction = AWXConfirmPaymentNextAction.decode(fromJSON: [
            "type" : "redirect_form",
            "method": "mock_method",
            "url": AWXThreeDSReturnURL
        ]) as! AWXConfirmPaymentNextAction
        mockProvider.paymentConsent = mockConsent
        mockSessionHandler.provider(mockProvider, shouldHandle: nextAction)
        XCTAssertEqual(mockPaymentResultDelegate.status, .failure)
        XCTAssertNotNil(mockSessionHandler.actionProvider)
        XCTAssertNotNil(mockSessionHandler.actionProvider?.paymentConsent)
        XCTAssertEqual(mockSessionHandler.actionProvider?.paymentConsent?.id, mockConsent.id)
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
    
    func testProviderShouldPresentController_ForceDismiss() {
        let controller = UIViewController()
        mockPaymentResultDelegate.presentedViewControllerSpy = controller
        mockSessionHandler.provider(mockProvider, shouldPresent: nil, forceToDismiss: true, withAnimation: false)
        XCTAssertNil(mockPaymentResultDelegate.presentedViewControllerSpy)
        
        mockPaymentResultDelegate.presentedViewControllerSpy = controller
        let controller2 = UIViewController()
        mockSessionHandler.provider(mockProvider, shouldPresent: controller2, forceToDismiss: true, withAnimation: false)
        XCTAssertEqual(controller2, mockPaymentResultDelegate.presentedViewControllerSpy)
    }
    
    // MARK: - Tests for canHandle method
    func testCanHandleWithInvalidTransactionMode() {
        // Setup method type with different transaction mode than session
        let methodType = AWXPaymentMethodType()
        methodType.name = "test_method"
        methodType.displayName = "Test Method"
        methodType.transactionMode = AWXPaymentTransactionModeRecurring
        
        // Session is oneoff by default
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return"
        )
        
        // Should return false when transaction modes don't match
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
    }
    
    func testCanHandleWithEmptyDisplayName() {
        // Setup method type with empty display name
        let methodType = AWXPaymentMethodType()
        methodType.name = "test_method"
        methodType.displayName = "" // Empty display name
        methodType.transactionMode = AWXPaymentTransactionModeOneOff
        
        // Create matching session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return"
        )
        
        // Should return false when display name is empty
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
    }
    
    func testCanHandleWithEmptyMethodName() {
        // Setup method type with empty method name
        let methodType = AWXPaymentMethodType()
        methodType.name = "" // Empty method name
        methodType.displayName = "Test Method"
        methodType.transactionMode = AWXPaymentTransactionModeOneOff
        
        // Create matching session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return"
        )
        
        // Should return false when method name is empty
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
    }
    
    func testCanHandleWithCardPayment() {
        // Setup card payment method
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        methodType.displayName = "Card"
        methodType.transactionMode = AWXPaymentTransactionModeOneOff
        methodType.cardSchemes = AWXCardScheme.allAvailable
        
        // Create matching session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return"
        )
        
        // Should return true for valid card payment method
        XCTAssertTrue(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
        
        // Remove card schemes to make it invalid
        methodType.cardSchemes = []
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
    }
    
    func testCanHandleWithApplePay() {
        // Setup Apple Pay method
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        methodType.displayName = "Apple Pay"
        methodType.transactionMode = AWXPaymentTransactionModeOneOff
        
        // Create matching session with Apple Pay options
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return",
            applePayOptions: AWXApplePayOptions(merchantIdentifier: "merchant_id")
        )
        session.applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant_id")
        session.applePayOptions?.supportedNetworks = [.visa, .masterCard]
        
        // Should return true for valid Apple Pay configuration
        XCTAssertTrue(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
        
        // Remove Apple Pay options to make it invalid
        session.applePayOptions = nil
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
    }
    
    func testCanHandleWithWeChatPay() {
        // Setup WeChat Pay method
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXWeChatPayKey
        methodType.displayName = "WeChat Pay"
        methodType.transactionMode = AWXPaymentTransactionModeOneOff
        
        // Create matching session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return"
        )
        
        // The result depends on whether WechatOpenSDKDynamic is available
        // This test is more to ensure code coverage than actual functionality testing
        // since we can't control SDK availability in the test
        #if canImport(WechatOpenSDKDynamic)
        XCTAssertTrue(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
        #else
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
        #endif
    }
    
    func testCanHandleWithDefaultProvider() {
        // Setup a generic payment method that would use the default provider
        let methodType = AWXPaymentMethodType()
        methodType.name = "some_other_method"
        methodType.displayName = "Other Payment Method"
        methodType.transactionMode = AWXPaymentTransactionModeOneOff
        methodType.resources = AWXResources()
        methodType.resources.hasSchema = true
        
        // Create matching session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com/return"
        )
        
        XCTAssertTrue(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
        methodType.resources.hasSchema = false
        XCTAssertFalse(PaymentSessionHandler.canHandle(methodType: methodType, session: session))
    }
    
    // MARK: - Apple Pay Happy Path Test
    
    func testApplePayHappyPath() async {
        // Setup Apple Pay method type
        mockMethodType.name = AWXApplePayKey
        mockMethodType.displayName = "Apple Pay"
        
        // Setup Apple Pay options
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant.id")
        mockSession.applePayOptions?.supportedNetworks = [.visa, .masterCard]
        
        // Create mock provider factory with a success-returning MockApplePayProvider
        let mockFactory = MockProviderFactory()
        let mockApplePayProvider = MockApplePayProvider(
            delegate: mockSessionHandler,
            session: mockSession,
            methodType: mockMethodType,
            shouldSucceed: true
        )
        mockFactory.mockApplePayProvider = mockApplePayProvider
        
        // Inject mock factory into session handler
        mockSessionHandler.providerFactory = mockFactory
        
        // Start Apple Pay payment
        mockSessionHandler.startApplePay()
        
        // Add sleep to wait for async status updates
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify success was called on the delegate
        await MainActor.run {
            XCTAssertEqual(mockPaymentResultDelegate.status, .success)
            XCTAssertNil(mockPaymentResultDelegate.error)
        }
        
        // Verify the mock provider was used
        XCTAssertTrue(mockFactory.applePayProviderCalled)
        XCTAssertTrue(mockApplePayProvider.startPaymentCalled)
        XCTAssertTrue(mockApplePayProvider.cancelPaymentOnDismissValue)
    }
    // MARK: - Card Payment Happy Path Test
    
    func testCardPaymentHappyPath() async {
        // Setup Card method type
        mockMethodType.name = AWXCardKey
        mockMethodType.displayName = "Card"
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        
        // Create valid card and billing info
        let card = AWXCard(
            name: "John Doe",
            cardNumber: "4111111111111111",
            expiryMonth: "12",
            expiryYear: "33",
            cvc: "123"
        )
        
        let billing = AWXPlaceDetails()
        billing.firstName = "John"
        billing.lastName = "Doe"
        billing.address = mockAddress
        
        // Create mock provider factory with a success-returning MockCardProvider
        let mockFactory = MockProviderFactory()
        let mockCardProvider = MockCardProvider(
            delegate: mockSessionHandler,
            session: mockSession,
            methodType: mockMethodType,
            shouldSucceed: true
        )
        mockFactory.mockCardProvider = mockCardProvider
        
        // Inject mock factory into session handler
        mockSessionHandler.providerFactory = mockFactory
        
        // Start Card payment
        mockSessionHandler.startCardPayment(with: card, billing: billing)
        
        // Add sleep to wait for async status updates
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify success was called on the delegate
        await MainActor.run {
            XCTAssertEqual(mockPaymentResultDelegate.status, .success)
            XCTAssertNil(mockPaymentResultDelegate.error)
        }
        
        // Verify the mock provider was used
        XCTAssertTrue(mockFactory.cardProviderCalled)
        XCTAssertTrue(mockCardProvider.startPaymentCalled)
        XCTAssertEqual(mockCardProvider.lastCardUsed?.number, card.number)
        XCTAssertEqual(mockCardProvider.lastBillingUsed?.firstName, billing.firstName)
    }
    
    // MARK: - Consent Payment Happy Path Test
    
    func testConsentPaymentHappyPath() async {
        // Setup Card method type for consent payment
        mockMethodType.name = AWXCardKey
        mockMethodType.displayName = "Card"
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        
        // Create valid consent
        let consent = AWXPaymentConsent()
        consent.id = "cst_123456789"
        
        // Create mock provider factory with a success-returning MockCardProvider
        let mockFactory = MockProviderFactory()
        let mockCardProvider = MockCardProvider(
            delegate: mockSessionHandler,
            session: mockSession,
            methodType: mockMethodType,
            shouldSucceed: true
        )
        mockFactory.mockCardProvider = mockCardProvider
        
        // Inject mock factory into session handler
        mockSessionHandler.providerFactory = mockFactory
        
        // Start Consent payment
        mockSessionHandler.startConsentPayment(with: consent)
        
        // Add sleep to wait for async status updates
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify success was called on the delegate
        await MainActor.run {
            XCTAssertEqual(mockPaymentResultDelegate.status, .success)
            XCTAssertNil(mockPaymentResultDelegate.error)
        }
        
        // Verify the mock provider was used
        XCTAssertTrue(mockFactory.cardProviderCalled)
        XCTAssertTrue(mockCardProvider.startConsentPaymentCalled)
        XCTAssertEqual(mockCardProvider.lastConsentUsed?.id, consent.id)
    }
    
    func testConsentPaymentHappyPathWithID() async {
        // Setup Card method type for consent payment
        mockMethodType.name = AWXCardKey
        mockMethodType.displayName = "Card"
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        
        // Create valid consent
        let consent = AWXPaymentConsent()
        consent.id = "cst_123456789"
        
        // Create mock provider factory with a success-returning MockCardProvider
        let mockFactory = MockProviderFactory()
        let mockCardProvider = MockCardProvider(
            delegate: mockSessionHandler,
            session: mockSession,
            methodType: mockMethodType,
            shouldSucceed: true
        )
        mockFactory.mockCardProvider = mockCardProvider
        
        // Inject mock factory into session handler
        mockSessionHandler.providerFactory = mockFactory
        
        // Start Consent payment
        mockSessionHandler.startConsentPayment(withId: consent.id)
        
        // Add sleep to wait for async status updates
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify success was called on the delegate
        await MainActor.run {
            XCTAssertEqual(mockPaymentResultDelegate.status, .success)
            XCTAssertNil(mockPaymentResultDelegate.error)
        }
        
        // Verify the mock provider was used
        XCTAssertTrue(mockFactory.cardProviderCalled)
        XCTAssertTrue(mockCardProvider.startConsentPaymentCalled)
        XCTAssertEqual(mockCardProvider.lastConsentIdUsed, consent.id)
    }
    
    // MARK: - Redirect Payment Happy Path Test
    
    func testRedirectPaymentHappyPath() async {
        // Setup Redirect method type
        mockMethodType.name = "wechatpay" // Example redirect payment method
        mockMethodType.displayName = "WeChat Pay"
        
        // Create mock provider factory with a success-returning MockRedirectProvider
        let mockFactory = MockProviderFactory()
        let mockRedirectProvider = MockRedirectProvider(
            delegate: mockSessionHandler,
            session: mockSession,
            methodType: mockMethodType,
            shouldSucceed: true
        )
        mockFactory.mockRedirectProvider = mockRedirectProvider
        
        // Inject mock factory into session handler
        mockSessionHandler.providerFactory = mockFactory
        
        // Start Redirect payment
        mockSessionHandler.startRedirectPayment(with: "wechatpay", additionalInfo: ["key": "value"])
        
        // Add sleep to wait for async status updates
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify success was called on the delegate
        await MainActor.run {
            XCTAssertEqual(mockPaymentResultDelegate.status, .success)
            XCTAssertNil(mockPaymentResultDelegate.error)
        }
        
        // Verify the mock provider was used
        XCTAssertTrue(mockFactory.redirectProviderCalled)
        XCTAssertTrue(mockRedirectProvider.startPaymentCalled)
        XCTAssertEqual(mockRedirectProvider.lastPaymentMethodUsed, "wechatpay")
    }
}
