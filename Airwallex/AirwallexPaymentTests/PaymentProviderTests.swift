//
//  PaymentProviderTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 28/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
import UIKit
import XCTest

class PaymentProviderTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var mockDelegate: MockProviderDelegate!
    private var mockSession: Session!
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockApiClient: AWXAPIClient!
    private var mockMethodType: AWXPaymentMethodType!
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        
        // Set up mock URL protocol for network testing
        MockURLProtocol.resetMockResponses()
        
        // Create mock payment intent
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.id = "test_intent_id"
        mockPaymentIntent.clientSecret = "test_client_secret"
        mockPaymentIntent.amount = NSDecimalNumber(string: "10.00")
        mockPaymentIntent.currency = "USD"
        mockPaymentIntent.customerId = "test_customer_id"
        
        // Create mock session
        mockSession = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com"
        )
        
        // Create mock payment method type
        mockMethodType = AWXPaymentMethodType()
        mockMethodType.name = AWXCardKey
        
        // Create mock provider delegate
        mockDelegate = MockProviderDelegate()
        
        // Create mock API client with MockURLProtocol
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockApiClient = AWXAPIClient(configuration: clientConfiguration)
    }
    
    override func tearDown() {
        mockDelegate = nil
        mockSession = nil
        mockPaymentIntent = nil
        mockApiClient = nil
        mockMethodType = nil
        MockURLProtocol.resetMockResponses()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitWithValidParameters() {
        // Test initialization with valid parameters
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Verify properties are correctly initialized
        XCTAssertTrue(provider.delegate === mockDelegate)
        XCTAssertTrue(provider.session === mockSession)
        XCTAssertEqual(provider.paymentMethodType, mockMethodType)
        XCTAssertTrue(provider.apiClient === mockApiClient)
    }
    
    // MARK: - Helper Method Tests
    
    func testCreatePaymentMethodOptionsForCard() {
        // Create a provider
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType
        )
        
        // Create a card payment method
        let cardMethod = AWXPaymentMethod()
        cardMethod.type = AWXCardKey
        
        // Test creating options for card payment
        let options = provider.createPaymentMethodOptions(cardMethod)
        
        // Verify options are correctly created
        XCTAssertNotNil(options)
        XCTAssertNotNil(options?.cardOptions)
        XCTAssertEqual(options?.cardOptions?.autoCapture, mockSession.autoCapture)
        XCTAssertNotNil(options?.cardOptions?.threeDs)
        XCTAssertEqual(options?.cardOptions?.threeDs?.returnURL, AWXThreeDSReturnURL)
    }
    
    func testCreatePaymentMethodOptionsForApplePay() {
        // Create a provider
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType
        )
        
        // Create an Apple Pay payment method
        let applePayMethod = AWXPaymentMethod()
        applePayMethod.type = AWXApplePayKey
        
        // Test creating options for Apple Pay
        let options = provider.createPaymentMethodOptions(applePayMethod)
        
        // Verify options are correctly created
        XCTAssertNotNil(options)
        XCTAssertNotNil(options?.cardOptions)
        XCTAssertEqual(options?.cardOptions?.autoCapture, mockSession.autoCapture)
        XCTAssertNil(options?.cardOptions?.threeDs) // No 3DS for Apple Pay
    }
    
    func testCreatePaymentMethodOptionsForUnsupportedMethod() {
        // Create a provider
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType
        )
        
        // Create an unsupported payment method
        let unsupportedMethod = AWXPaymentMethod()
        unsupportedMethod.type = "unsupported_method"
        
        // Test creating options for unsupported method
        let options = provider.createPaymentMethodOptions(unsupportedMethod)
        
        // Verify no options are created for unsupported methods
        XCTAssertNil(options)
    }
    
    func testCreateConfirmIntentRequestWithMethod() async throws {
        // Create a provider
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType
        )
        
        // Create a payment method
        let method = AWXPaymentMethod()
        method.type = AWXCardKey
        
        // Test creating confirm intent request with method
        let request = try await provider.createConfirmIntentRequest(method: method, consent: nil, consentOptions: nil)
        
        // Verify request is correctly configured
        XCTAssertEqual(request.intentId, mockPaymentIntent.id)
        XCTAssertEqual(request.customerId, mockPaymentIntent.customerId)
        XCTAssertEqual(request.paymentMethod, method)
        XCTAssertNil(request.paymentConsent)
        XCTAssertNotNil(request.device)
        XCTAssertEqual(request.returnURL, AWXThreeDSReturnURL)
        XCTAssertNotNil(request.options)
        XCTAssertNil(request.consentOptions)
    }
    
    func testCreateConfirmIntentRequestWithConsent() async throws{
        // Create a provider
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType
        )
        
        // Create a payment consent
        let consent = AWXPaymentConsent()
        consent.id = "test_consent_id"
        
        // Test creating confirm intent request with consent
        let request = try await provider.createConfirmIntentRequest(method: nil, consent: consent, consentOptions: nil)
        
        // Verify request is correctly configured
        XCTAssertEqual(request.intentId, mockPaymentIntent.id)
        XCTAssertEqual(request.customerId, mockPaymentIntent.customerId)
        XCTAssertNil(request.paymentMethod)
        XCTAssertEqual(request.paymentConsent, consent)
        XCTAssertNotNil(request.device)
        XCTAssertEqual(request.returnURL, AWXThreeDSReturnURL)
        XCTAssertNil(request.options)
        XCTAssertNil(request.consentOptions)
    }
    
    func testCreateConfirmIntentRequestWithConsentOptions() async throws {
        // Create a provider
        let provider = PaymentProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType
        )
        
        // Create a payment consent
        let consent = AWXPaymentConsent()
        consent.id = "test_consent_id"
        
        // Test creating confirm intent request with consent
        let request = try await provider.createConfirmIntentRequest(
            method: nil,
            consent: consent,
            consentOptions: PaymentConsentOptions(
                nextTriggeredBy: .merchantType,
                merchantTriggerReason: .installments
            )
        )
        
        // Verify request is correctly configured
        XCTAssertNotNil(request.consentOptions)
        XCTAssertEqual(request.consentOptions?["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(request.consentOptions?["merchant_trigger_reason"] as? String, "installments")
    }
}
