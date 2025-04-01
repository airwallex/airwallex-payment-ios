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
    private var mockAddress: AWXAddress!
    
    private var mockMethodType: AWXPaymentMethodType!
    private var mockSessionHandler: PaymentSessionHandler!
    private var mockProvider: AWXDefaultProvider!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockPaymentResultDelegate = MockPaymentResultDelegate()
        mockSession = AWXOneOffSession()
        mockMethodType = AWXPaymentMethodType()
        mockMethodType.name = AWXCardKey
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.clientSecret = mockClientSecret
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
            methodType: mockMethodType
        )
        XCTAssertTrue(handler.paymentResultDelegate === mockPaymentResultDelegate)
        XCTAssertFalse(handler.viewController === mockPaymentResultDelegate)
        XCTAssertTrue(handler.viewController === viewController)
        XCTAssertEqual(handler.methodType, mockMethodType)
        XCTAssertEqual(handler.session, mockSession)
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
        let consent = AWXPaymentConsent()
        consent.id = ""
        mockSessionHandler.startConsentPayment(with: consent)
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
