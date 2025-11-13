//
//  ProviderFactoryTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
import UIKit
import XCTest

class ProviderFactoryTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockSession: Session!
    private var mockOneOffSession: AWXOneOffSession!
    private var mockRecurringWithIntentSession: AWXRecurringWithIntentSession!
    private var mockRecurringSession: AWXRecurringSession!
    private var mockDelegate: MockProviderDelegate!
    private var mockMethodType: AWXPaymentMethodType!
    private var factory: ProviderFactory!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Create mock payment intent
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        paymentIntent.amount = NSDecimalNumber(string: "10.00")
        paymentIntent.currency = "USD"
        paymentIntent.clientSecret = "mock_client_secret"
        paymentIntent.customerId = "customer_id"
        mockPaymentIntent = paymentIntent
        
        // Create mock unified session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com"
        )
        mockSession = session
        
        // Create mock one-off session (convertible to Session)
        let oneOffSession = AWXOneOffSession()
        oneOffSession.paymentIntent = mockPaymentIntent
        oneOffSession.countryCode = "US"
        oneOffSession.returnURL = "https://example.com"
        oneOffSession.autoCapture = true
        oneOffSession.autoSaveCardForFuturePayments = true
        mockOneOffSession = oneOffSession
        
        // Create mock recurring with intent session (convertible to Session)
        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        recurringWithIntentSession.countryCode = "US"
        recurringWithIntentSession.returnURL = "https://example.com"
        recurringWithIntentSession.autoCapture = true
        recurringWithIntentSession.nextTriggerByType = .merchantType
        recurringWithIntentSession.merchantTriggerReason = .unscheduled
        mockRecurringWithIntentSession = recurringWithIntentSession
        
        // Create mock recurring session (not convertible to Session)
        let recurringSession = AWXRecurringSession()
        recurringSession.setAmount(NSDecimalNumber(string: "10.00"))
        recurringSession.setCurrency("USD")
        recurringSession.setCustomerId("customer_id")
        recurringSession.countryCode = "US"
        recurringSession.returnURL = "https://example.com"
        recurringSession.nextTriggerByType = .merchantType
        recurringSession.merchantTriggerReason = .unscheduled
        mockRecurringSession = recurringSession
        
        // Create mock delegate
        mockDelegate = MockProviderDelegate()
        
        // Create mock payment method type
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        methodType.displayName = "Card"
        methodType.cardSchemes = AWXCardScheme.allAvailable
        mockMethodType = methodType
        
        // Create factory instance
        factory = ProviderFactory()
    }
    
    override func tearDown() {
        mockPaymentIntent = nil
        mockSession = nil
        mockOneOffSession = nil
        mockRecurringWithIntentSession = nil
        mockRecurringSession = nil
        mockDelegate = nil
        mockMethodType = nil
        factory = nil
        super.tearDown()
    }
    
    // MARK: - Apple Pay Provider Tests
    
    func testApplePayProviderWithUnifiedSession() {
        // Configure for Apple Pay
        mockMethodType.name = AWXApplePayKey
        
        // Get provider
        let provider = factory.applePayProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: mockMethodType
        )
        
        // Verify correct provider type
        XCTAssertTrue(provider is ApplePayProvider)
    }
    
    func testApplePayProviderWithOneOffSession() {
        // Configure for Apple Pay
        mockMethodType.name = AWXApplePayKey
        
        // Get provider
        let provider = factory.applePayProvider(
            delegate: mockDelegate,
            session: mockOneOffSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - should be ApplePayProvider since AWXOneOffSession is convertible to Session
        XCTAssertTrue(provider is ApplePayProvider)
    }
    
    func testApplePayProviderWithRecurringWithIntentSession() {
        // Configure for Apple Pay
        mockMethodType.name = AWXApplePayKey
        
        // Get provider
        let provider = factory.applePayProvider(
            delegate: mockDelegate,
            session: mockRecurringWithIntentSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - should be ApplePayProvider since AWXRecurringWithIntentSession is convertible to Session
        XCTAssertTrue(provider is ApplePayProvider)
    }
    
    func testApplePayProviderWithRecurringSession() {
        // Configure for Apple Pay
        mockMethodType.name = AWXApplePayKey
        
        // Get provider
        let provider = factory.applePayProvider(
            delegate: mockDelegate,
            session: mockRecurringSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - should be AWXApplePayProvider since AWXRecurringSession is not convertible to Session
        XCTAssertTrue(provider is AWXApplePayProvider)
    }
    
    // MARK: - Card Provider Tests
    
    func testCardProviderWithUnifiedSession() {
        // Configure for Card payment
        mockMethodType.name = AWXCardKey
        
        // Get provider
        let provider = factory.cardProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: mockMethodType
        )
        
        // Verify correct provider type
        XCTAssertTrue(provider is CardProvider)
    }
    
    func testCardProviderWithOneOffSession() {
        // Configure for Card payment
        mockMethodType.name = AWXCardKey
        
        // Get provider
        let provider = factory.cardProvider(
            delegate: mockDelegate,
            session: mockOneOffSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - should be CardProvider since AWXOneOffSession is convertible to Session
        XCTAssertTrue(provider is CardProvider)
    }
    
    func testCardProviderWithRecurringWithIntentSession() {
        // Configure for Card payment
        mockMethodType.name = AWXCardKey
        
        // Get provider
        let provider = factory.cardProvider(
            delegate: mockDelegate,
            session: mockRecurringWithIntentSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - should be CardProvider since AWXRecurringWithIntentSession is convertible to Session
        XCTAssertTrue(provider is CardProvider)
    }
    
    func testCardProviderWithRecurringSession() {
        // Configure for Card payment
        mockMethodType.name = AWXCardKey
        
        // Get provider
        let provider = factory.cardProvider(
            delegate: mockDelegate,
            session: mockRecurringSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - should be AWXCardProvider since AWXRecurringSession is not convertible to Session
        XCTAssertTrue(provider is AWXCardProvider)
    }
    
    // MARK: - Redirect Provider Tests
    
    func testRedirectProviderWithUnifiedSession() async throws {
        // Configure for redirect payment
        mockMethodType.name = "paypal"
        mockMethodType.resources = AWXResources()
        mockMethodType.resources.hasSchema = true
        
        // Get provider
        let provider = try await factory.redirectProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - always AWXRedirectActionProvider, but with converted session
        XCTAssertTrue(provider is AWXRedirectActionProvider)
    }
    
    func testRedirectProviderWithOneOffSession() async throws {
        // Configure for redirect payment
        mockMethodType.name = "paypal"
        mockMethodType.resources = AWXResources()
        mockMethodType.resources.hasSchema = true
        
        // Get provider
        let provider = try await factory.redirectProvider(
            delegate: mockDelegate,
            session: mockOneOffSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - always AWXRedirectActionProvider
        XCTAssertTrue(provider is AWXRedirectActionProvider)
    }
    
    func testRedirectProviderWithRecurringWithIntentSession() async throws {
        // Configure for redirect payment
        mockMethodType.name = "paypal"
        mockMethodType.resources = AWXResources()
        mockMethodType.resources.hasSchema = true
        
        // Get provider
        let provider = try await factory.redirectProvider(
            delegate: mockDelegate,
            session: mockRecurringWithIntentSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - always AWXRedirectActionProvider
        XCTAssertTrue(provider is AWXRedirectActionProvider)
    }
    
    func testRedirectProviderWithRecurringSession() async throws {
        // Configure for redirect payment
        mockMethodType.name = "paypal"
        mockMethodType.resources = AWXResources()
        mockMethodType.resources.hasSchema = true
        
        // Get provider
        let provider = try await factory.redirectProvider(
            delegate: mockDelegate,
            session: mockRecurringSession,
            type: mockMethodType
        )
        
        // Verify correct provider type - always AWXRedirectActionProvider
        XCTAssertTrue(provider is AWXRedirectActionProvider)
    }
    
    // MARK: - Edge Cases
    
    func testProviderFactoryWithNilMethodType() async throws {
        // Test with nil method type
        
        // Apple Pay Provider
        let applePayProvider = factory.applePayProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: nil
        )
        XCTAssertNotNil(applePayProvider)
        
        // Card Provider
        let cardProvider = factory.cardProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: nil
        )
        XCTAssertNotNil(cardProvider)
        
        // Redirect Provider
        let redirectProvider = try await factory.redirectProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: nil
        )
        XCTAssertNotNil(redirectProvider)
    }
    
    func testProviderFactoryWithRecurringSession() async throws {
        // Setup recurring session
        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType)
        mockSession = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            paymentConsentOptions: consentOptions,
            returnURL: "https://example.com"
        )
        
        // Verify with all provider types
        
        // Apple Pay Provider
        mockMethodType.name = AWXApplePayKey
        let applePayProvider = factory.applePayProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: mockMethodType
        )
        XCTAssertTrue(applePayProvider is ApplePayProvider)
        
        // Card Provider
        mockMethodType.name = AWXCardKey
        let cardProvider = factory.cardProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: mockMethodType
        )
        XCTAssertTrue(cardProvider is CardProvider)
        
        // Redirect Provider
        mockMethodType.name = "paypal"
        let redirectProvider = try await factory.redirectProvider(
            delegate: mockDelegate,
            session: mockSession,
            type: mockMethodType
        )
        XCTAssertTrue(redirectProvider is AWXRedirectActionProvider)
    }
}
