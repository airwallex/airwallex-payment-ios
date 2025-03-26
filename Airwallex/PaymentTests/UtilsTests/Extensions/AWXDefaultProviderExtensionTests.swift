//
//  AWXDefaultProviderExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
import Core
@testable import Payment
import ApplePay
import Card
import Redirect

class AWXDefaultProviderExtensionTests: XCTestCase {
    
    private var mockPaymentResultDelegate: MockPaymentResultDelegate!
    private var mockProviderDelegate: MockProviderDelegate!
    private var mockSession: AWXOneOffSession!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockApplePayOptions: AWXApplePayOptions!
    
    private var mockMethodType: AWXPaymentMethodType!
    private var mockValidCard: AWXCard!
    private var mockValidBilling: AWXPlaceDetails!
    

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockPaymentResultDelegate = MockPaymentResultDelegate()
        mockMethodType = AWXPaymentMethodType()
        mockMethodType.name = AWXCardKey
        mockMethodType.cardSchemes = AWXCardScheme.allAvailable
        mockProviderDelegate = MockProviderDelegate()
        
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.clientSecret = mockClientSecret
        
        mockApplePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant_id")

        mockSession = AWXOneOffSession()
        mockSession.paymentIntent = mockPaymentIntent
        mockSession.applePayOptions = mockApplePayOptions
        
        mockValidCard = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiry: "12/2030", cvc: "123")
        let billing = AWXPlaceDetails()
        let address = AWXAddress()
        address.street = "street"
        address.city = "city"
        address.state = "state"
        address.countryCode = "AU"
        address.postcode = "1234"
        billing.address = address
        billing.firstName = "John"
        billing.lastName = "Doe"
        billing.email = "test@test.com"
        billing.phoneNumber = "+1234567890"
        mockValidBilling = billing
    }
    
    func testApplePayProviderInvalidMethodType() {
        mockMethodType.name = AWXCardKey
        let provider = AWXApplePayProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        XCTAssertThrowsError(try provider.validate()) { error in
            guard case AWXApplePayProvider.ValidationError.invalidMethodType(_) = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidMethodType, but get \(error)")
                return
            }
        }
    }

    func testApplePayProviderInvalidApplePayOptions() {
        mockMethodType.name = AWXApplePayKey
        let provider = AWXApplePayProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        mockSession.applePayOptions = mockApplePayOptions
        XCTAssertNoThrow(try provider.validate())

        // nil applePayOptions
        mockSession.applePayOptions = nil
        XCTAssertThrowsError(try provider.validate()) { error in
            guard case AWXApplePayProvider.ValidationError.invalidApplePayOptions(_) = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions, but got \(error)")
                return
            }
        }
        
        // applePayOption with invalid merchant identifier
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "")
        XCTAssertThrowsError(try provider.validate()) { error in
            guard case AWXApplePayProvider.ValidationError.invalidApplePayOptions(_) = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions, but got \(error)")
                return
            }
        }
        
        // invalid payment network
        mockSession.applePayOptions = mockApplePayOptions
        mockApplePayOptions.supportedNetworks = [.cartesBancaires]
        XCTAssertThrowsError(try provider.validate()) { error in
            guard case AWXApplePayProvider.ValidationError.invalidApplePayOptions(_) = error else {
                XCTFail("Expected AWXApplePayProvider.ValidationError.invalidApplePayOptions, but got \(error)")
                return
            }
        }
    }
    
    func testCardProviderValidateWithCard() {
        mockMethodType.name = AWXCardKey
        let provider = AWXCardProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        
        // Test valid card and billing
        XCTAssertNoThrow(try provider.validate(card: mockValidCard, billing: mockValidBilling))
        
        // Test invalid method type
        mockMethodType.name = AWXApplePayKey
        XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: mockValidBilling)) { error in
            guard case AWXCardProvider.ValidationError.invalidMethodType(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidMethodType, but got \(error)")
                return
            }
        }
        
        // Test invalid card number
        mockMethodType.name = AWXCardKey
        let invalidCard = AWXCard(name: "John Doe", cardNumber: "123", expiry: "12/2030", cvc: "123")
        XCTAssertThrowsError(try provider.validate(card: invalidCard, billing: mockValidBilling)) { error in
            guard case AWXCardProvider.ValidationError.invalidCardInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo, but got \(error)")
                return
            }
        }
        
        // Test invalid card cvc
        let invalidCardCVC = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiry: "12/2030", cvc: "1111")
        XCTAssertThrowsError(try provider.validate(card: invalidCardCVC, billing: mockValidBilling)) { error in
            guard case AWXCardProvider.ValidationError.invalidCardInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo, but got \(error)")
                return
            }
        }
        
        // Test invalid card expiry
        let invalidCardExpiry = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiry: "", cvc: "111")
        XCTAssertThrowsError(try provider.validate(card: invalidCardExpiry, billing: mockValidBilling)) { error in
            guard case AWXCardProvider.ValidationError.invalidCardInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo, but got \(error)")
                return
            }
        }
        
        // Test invalid card holder name
        let invalidCardHolder = AWXCard(name: "", cardNumber: "4111111111111111", expiry: "", cvc: "111")
        XCTAssertThrowsError(try provider.validate(card: invalidCardHolder, billing: mockValidBilling)) { error in
            guard case AWXCardProvider.ValidationError.invalidCardInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidCardInfo, but got \(error)")
                return
            }
        }
    }
    
    func testCardProviderValidateWithBilling() {
        mockMethodType.name = AWXCardKey
        let provider = AWXCardProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        mockSession.requiredBillingContactFields = [.name, .email, .phone, .countryCode]

        // Test valid card and billing
        XCTAssertNoThrow(try provider.validate(card: mockValidCard, billing: mockValidBilling))
        
        // Test missing billing info
        XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: nil)) { error in
            guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                return
            }
        }
        
        // Test invalid billing name
        let invalidBillingName = mockValidBilling.copy() as! AWXPlaceDetails
        invalidBillingName.firstName = ""
        XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidBillingName)) { error in
            guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                return
            }
        }
        
        // Test invalid billing email
        let invalidBillingEmail = mockValidBilling.copy() as! AWXPlaceDetails
        for invalidEmail in ["invalid-email", nil, ""] {
            invalidBillingEmail.email = invalidEmail
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidBillingEmail)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
        
        // Test invalid country code
        let invalidBillingCountryCode = mockValidBilling.copy() as! AWXPlaceDetails
        for invalidCountryCode in ["XXX", nil, ""] {
            invalidBillingCountryCode.address?.countryCode = invalidCountryCode
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidBillingCountryCode)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
    }

    func testCardProviderValidateWithInvalidAddress() {
        mockMethodType.name = AWXCardKey
        let provider = AWXCardProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        mockSession.requiredBillingContactFields = [.address]
        XCTAssertNoThrow(try provider.validate(card: mockValidCard, billing: mockValidBilling))
        
        // Test missing address
        let invalidAddressNil = mockValidBilling.copy() as! AWXPlaceDetails
        invalidAddressNil.address = nil
        XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidAddressNil)) { error in
            guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                return
            }
        }
        
        // Test invalid country code
        let invalidAddressCountryCode = mockValidBilling.copy() as! AWXPlaceDetails
        for countryCode in ["XXX", nil, ""] {
            invalidAddressCountryCode.address?.countryCode = countryCode
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidAddressCountryCode)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
        
        // Test invalid state
        let invalidAddressState = mockValidBilling.copy() as! AWXPlaceDetails
        for string in ["", nil] {
            invalidAddressState.address?.state = string
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidAddressState)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
        
        // Test invalid city
        let invalidAddressCity = mockValidBilling.copy() as! AWXPlaceDetails
        for string in ["", nil] {
            invalidAddressCity.address?.city = string
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidAddressCity)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
        
        // Test invalid street
        let invalidAddressStreet = mockValidBilling.copy() as! AWXPlaceDetails
        for string in ["", nil] {
            invalidAddressStreet.address?.street = string
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidAddressStreet)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
        
        // Test invalid postcode
        let invalidAddressPostcode = mockValidBilling.copy() as! AWXPlaceDetails
        for string in ["", nil] {
            invalidAddressPostcode.address?.postcode = string
            XCTAssertThrowsError(try provider.validate(card: mockValidCard, billing: invalidAddressPostcode)) { error in
                guard case AWXCardProvider.ValidationError.invalidBillingInfo(_) = error else {
                    XCTFail("Expected AWXCardProvider.ValidationError.invalidBillingInfo, but got \(error)")
                    return
                }
            }
        }
    }

    func testCardProviderValidateWithConsent() {
        mockMethodType.name = AWXCardKey
        let provider = AWXCardProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        
        // Test valid consent
        let validConsent = AWXPaymentConsent()
        validConsent.id = "cst_validConsentId"
        XCTAssertNoThrow(try provider.validate(consent: validConsent))
        
        // Test invalid consent ID
        mockMethodType.name = AWXCardKey
        let invalidConsent = AWXPaymentConsent()
        invalidConsent.id = "invalidConsentId"
        XCTAssertThrowsError(try provider.validate(consent: invalidConsent)) { error in
            guard case AWXCardProvider.ValidationError.invalidConsent(_) = error else {
                XCTFail("Expected AWXCardProvider.ValidationError.invalidConsent, but got \(error)")
                return
            }
        }
    }

    func testRedirectActionProviderValidate() {
        let provider = AWXRedirectActionProvider(delegate: mockProviderDelegate, session: mockSession, paymentMethodType: mockMethodType)
        
        // Test valid method name
        mockMethodType.name = "redirect"
        XCTAssertNoThrow(try provider.validate(name: "redirect"))
        
        // Test invalid method name
        XCTAssertThrowsError(try provider.validate(name: "invalidName")) { error in
            guard case AWXRedirectActionProvider.ValidationError.invalidMethodType(_) = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType, but got \(error)")
                return
            }
        }
        
        // Test invalid method type for card payment
        mockMethodType.name = AWXCardKey
        XCTAssertThrowsError(try provider.validate(name: AWXCardKey)) { error in
            guard case AWXRedirectActionProvider.ValidationError.invalidMethodType(_) = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType, but got \(error)")
                return
            }
        }
        
        // Test invalid method type for Apple Pay
        mockMethodType.name = AWXApplePayKey
        XCTAssertThrowsError(try provider.validate(name: AWXApplePayKey)) { error in
            guard case AWXRedirectActionProvider.ValidationError.invalidMethodType(_) = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidMethodType, but got \(error)")
                return
            }
        }
        
        // Test invalid session
        mockSession.paymentIntent = nil
        mockMethodType.name = "redirect"
        XCTAssertThrowsError(try provider.validate(name: "redirect")) { error in
            guard case AWXRedirectActionProvider.ValidationError.invalidSession(_) = error else {
                XCTFail("Expected AWXRedirectActionProvider.ValidationError.invalidSession, but got \(error)")
                return
            }
        }
    }

}
