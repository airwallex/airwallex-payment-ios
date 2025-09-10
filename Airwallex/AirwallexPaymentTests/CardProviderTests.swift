//
//  CardProviderTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 28/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
import UIKit
import XCTest

class CardProviderTests: XCTestCase {
    
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockSession: Session!
    private var mockApiClient: AWXAPIClient!
    private var mockDelegate: MockProviderDelegate!
    private var mockMethodType: AWXPaymentMethodType!
    
    override func setUp() {
        super.setUp()
        
        // Reset mock URL protocol
        MockURLProtocol.resetMockResponses()
        
        // Create mock payment intent
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        paymentIntent.amount = NSDecimalNumber(string: "10.00")
        paymentIntent.currency = "USD"
        paymentIntent.clientSecret = "mock_client_secret"
        mockPaymentIntent = paymentIntent
        
        // Create mock session
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            returnURL: "https://example.com"
        )
        mockSession = session
        
        // Create mock API client
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockApiClient = AWXAPIClient(configuration: clientConfiguration)
        
        // Create mock delegate
        mockDelegate = MockProviderDelegate()
        
        // Create mock payment method type
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        
        // Create card schemes
        let visaScheme = AWXCardScheme()
        visaScheme.name = "visa"
        let mastercardScheme = AWXCardScheme()
        mastercardScheme.name = "mastercard"
        methodType.cardSchemes = [visaScheme, mastercardScheme]
        
        mockMethodType = methodType
    }
    
    override func tearDown() {
        // Clean up after each test
        super.tearDown()
        mockPaymentIntent = nil
        mockSession = nil
        mockApiClient = nil
        mockDelegate = nil
        MockURLProtocol.resetMockResponses()
    }
    
    // MARK: - canHandle Tests
    
    func testCanHandleWithValidSession() {
        // Test with valid session and payment method type
        XCTAssertTrue(CardProvider.canHandle(mockSession, paymentMethod: mockMethodType))
    }
    
    func testCanHandleWithInvalidSession() {
        // Test with invalid session types
        
        // Test with AWXOneOffSession
        let oneOffSession = AWXOneOffSession()
        oneOffSession.paymentIntent = mockPaymentIntent
        XCTAssertFalse(CardProvider.canHandle(oneOffSession, paymentMethod: mockMethodType))
        
        // Test with AWXRecurringSession
        let recurringSession = AWXRecurringSession()
        XCTAssertFalse(CardProvider.canHandle(recurringSession, paymentMethod: mockMethodType))
        
        // Test with AWXRecurringWithIntentSession
        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        XCTAssertFalse(CardProvider.canHandle(recurringWithIntentSession, paymentMethod: mockMethodType))
    }
    
    func testCanHandleWithInvalidPaymentMethod() {
        // Test with invalid payment method
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey // Not a card method
        
        XCTAssertFalse(CardProvider.canHandle(mockSession, paymentMethod: methodType))
    }
    
    // MARK: - confirmIntentWithCard Tests
    
    func testConfirmIntentWithCard() async {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Create test card and billing info
        let card = AWXCard()
        card.number = "4242424242424242"
        card.expiryMonth = "12"
        card.expiryYear = "2030"
        card.cvc = "123"
        
        let billing = AWXPlaceDetails()
        billing.firstName = "Test"
        billing.lastName = "User"
        
        // Call the method under test
        await provider.confirmIntentWithCard(card, billing: billing, saveCard: false)
        
        // Verify the API client was called correctly
        await MainActor.run {        
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithCardAndSave() async {
        // Configure a CardProvider
        // Set customer ID for card saving
        mockPaymentIntent.customerId = "customer_123"
        
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Create test card
        let card = AWXCard()
        card.number = "4242424242424242"
        card.expiryMonth = "12"
        card.expiryYear = "2030"
        card.cvc = "123"
        
        // Call the method under test with saveCard = true
        await provider.confirmIntentWithCard(card, saveCard: true)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithCardFailure() async {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return failure
        MockURLProtocol.mockFailure()
        
        // Create test card
        let card = AWXCard()
        card.number = "4242424242424242"
        card.expiryMonth = "12"
        card.expiryYear = "2030"
        card.cvc = "123"
        
        // Call the method under test
        await provider.confirmIntentWithCard(card, saveCard: false)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.failure)
            XCTAssertNotNil(mockDelegate.completionError)
        }
    }
    
    // MARK: - confirmIntentWithConsent (PaymentConsent object) Tests
    
    func testConfirmIntentWithConsentForRecurringPayment() async {
        // Set up recurring options
        mockSession = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "AU",
            returnURL: "https://www.example.com",
            paymentConsentOptions: PaymentConsentOptions(nextTriggeredBy: .merchantType)
        )
        
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Create test consent with payment method
        let consent = AWXPaymentConsent()
        consent.id = "consent_123"
        consent.nextTriggeredBy = FormatNextTriggerByType(.customerType)
        
        let method = AWXPaymentMethod()
        method.id = "method_123"
        method.type = AWXCardKey
        
        let card = AWXCard()
        card.cvc = "123"
        card.numberType = "PAN"
        method.card = card
        
        consent.paymentMethod = method
        
        // Call the method under test
        await provider.confirmIntentWithConsent(consent)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmSubsequentPaymentWithMITConsent() async {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Create test MIT consent
        let consent = AWXPaymentConsent()
        consent.id = "consent_123"
        consent.nextTriggeredBy = FormatNextTriggerByType(.merchantType) // This makes it an MIT consent
        
        let method = AWXPaymentMethod()
        method.id = "method_123"
        method.type = AWXCardKey
        
        consent.paymentMethod = method
        
        // Call the method under test
        await provider.confirmIntentWithConsent(consent)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmSubsequentPaymentWithCITConsent() async {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Create test CIT consent without method ID
        let consent = AWXPaymentConsent()
        consent.id = "consent_123"
        consent.nextTriggeredBy = FormatNextTriggerByType(.customerType) // This makes it a CIT consent
        
        // Call the method under test
        await provider.confirmIntentWithConsent(consent)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithConsentObjectAndCVCInput() async throws {
        // Configure a CardProvider with a mock delegate that provides a view controller
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        let consent = AWXPaymentConsent()
        consent.id = "consent_123"
        consent.nextTriggeredBy = FormatNextTriggerByType(.customerType)
        
        let method = AWXPaymentMethod()
        method.id = "method_123"
        method.type = AWXCardKey
        
        let card = AWXCard()
        card.numberType = "PAN"
        method.card = card
        
        consent.paymentMethod = method
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Call the method under test with requiresCVC = true
        async let task: () = provider.confirmIntentWithConsent(consent)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        try await MainActor.run {
            XCTAssertNotNil(mockDelegate.presentedViewControllerSpy)
            guard let cvcController = mockDelegate.presentedViewControllerSpy?.children.first as? AWXCardCVCViewController,
                  let cvcCallback = cvcController.cvcCallback else {
                throw "cvc input not work as expected".asError()
            }
            mockDelegate.dismiss(animated: false)
            cvcCallback("123", false)
        }
        await task
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertNil(mockDelegate.presentedViewControllerSpy)
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithConsentObjectAndCVCInputButCancelled() async throws {
        // Configure a CardProvider with a mock delegate that provides a view controller
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        let consent = AWXPaymentConsent()
        consent.id = "consent_123"
        consent.nextTriggeredBy = FormatNextTriggerByType(.customerType)
        
        let method = AWXPaymentMethod()
        method.id = "method_123"
        method.type = AWXCardKey
        
        let card = AWXCard()
        card.numberType = "PAN"
        method.card = card
        
        consent.paymentMethod = method
        
        // Call the method under test with requiresCVC = true
        async let task: () = provider.confirmIntentWithConsent(consent)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        try await MainActor.run {
            XCTAssertNotNil(mockDelegate.presentedViewControllerSpy)
            guard let cvcController = mockDelegate.presentedViewControllerSpy?.children.first as? AWXCardCVCViewController,
                  let cvcCallback = cvcController.cvcCallback else {
                throw "cvc input not work as expected".asError()
            }
            mockDelegate.dismiss(animated: false)
            cvcCallback("123", true)
        }
        await task
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.cancel)
            XCTAssertNil(mockDelegate.presentedViewControllerSpy)
            XCTAssertEqual(mockDelegate.didStartRequest, 0)
            XCTAssertEqual(mockDelegate.didEndRequest, 0)
        }
    }
    
    // MARK: - confirmIntentWithConsent (consentId string) Tests
    
    func testConfirmIntentWithConsentId() async {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Call the method under test
        await provider.confirmIntentWithConsent("consent_123", requiresCVC: false)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithConsentIdAndCVC() async throws {
        // Configure a CardProvider with a mock delegate that provides a view controller
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return success
        MockURLProtocol.mockSuccess()
        
        // Call the method under test with requiresCVC = true
        async let task: () = provider.confirmIntentWithConsent("consent_123", requiresCVC: true)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        try await MainActor.run {
            XCTAssertNotNil(mockDelegate.presentedViewControllerSpy)
            guard let cvcController = mockDelegate.presentedViewControllerSpy?.children.first as? AWXCardCVCViewController,
                  let cvcCallback = cvcController.cvcCallback else {
                throw "cvc input not work as expected".asError()
            }
            mockDelegate.dismiss(animated: false)
            cvcCallback("123", false)
        }
        await task
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertNil(mockDelegate.presentedViewControllerSpy)
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.success)
            XCTAssertNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithConsentIdFailure() async {
        // Configure a CardProvider
        
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Configure mock URL protocol to return failure
        MockURLProtocol.mockFailure()
        
        // Call the method under test
        await provider.confirmIntentWithConsent("consent_123", requiresCVC: false)
        
        // Verify the API client was called correctly
        await MainActor.run {
            XCTAssertEqual(mockDelegate.didStartRequest, 1)
            XCTAssertEqual(mockDelegate.didEndRequest, 1)
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.failure)
            XCTAssertNotNil(mockDelegate.completionError)
        }
    }
    
    func testConfirmIntentWithConsentIdCancelled() async throws {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Call the method under test with requiresCVC = true
        async let task: () = provider.confirmIntentWithConsent("consent_123", requiresCVC: true)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        try await MainActor.run {
            XCTAssertNotNil(mockDelegate.presentedViewControllerSpy)
            guard let cvcController = mockDelegate.presentedViewControllerSpy?.children.first as? AWXCardCVCViewController,
                  let cvcCallback = cvcController.cvcCallback else {
                throw "cvc input not work as expected".asError()
            }
            mockDelegate.dismiss(animated: false)
            cvcCallback("123", true)
        }
        await task
        
        // Verify the completion status
        await MainActor.run {
            XCTAssertEqual(mockDelegate.completionStatus, AirwallexPaymentStatus.cancel)
            XCTAssertNil(mockDelegate.completionError)
            XCTAssertNil(mockDelegate.presentedViewControllerSpy)
            XCTAssertEqual(mockDelegate.didStartRequest, 0)
            XCTAssertEqual(mockDelegate.didEndRequest, 0)
        }
    }
    
    // MARK: - Helper Method Tests
    
    func testCreateRequestForSubsequentTransaction() {
        // Configure a CardProvider
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: mockMethodType,
            apiClient: mockApiClient
        )
        
        // Test without CVC
        let request1 = provider.createPaymentRequestWithExistingConsent(consentId: "consent_123", cvc: nil)
        
        // Verify the request properties
        XCTAssertEqual(request1.paymentConsent?.id, "consent_123")
        XCTAssertNil(request1.paymentMethod)
        XCTAssertEqual(request1.intentId, mockPaymentIntent.id)
        
        // Test with CVC
        let request2 = provider.createPaymentRequestWithExistingConsent(consentId: "consent_123", cvc: "123")
        
        // Verify the request properties
        XCTAssertEqual(request2.paymentConsent?.id, "consent_123")
        XCTAssertEqual(request2.paymentMethod?.type, AWXCardKey)
        XCTAssertEqual(request2.paymentMethod?.card?.cvc, "123")
        XCTAssertEqual(request2.intentId, mockPaymentIntent.id)
    }
    
    func testCreateRequestForConsentConversion() {
        // Configure a CardProvider
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        
        let provider = CardProvider(
            delegate: mockDelegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient
        )
        
        // Test without CVC
        let request1 = provider.createPaymentRequestWithConsentCreation(
            methodId: "method_123",
            cvc: nil,
            consentOptions: PaymentConsentOptions(nextTriggeredBy: .customerType)
        )
        
        // Verify the request properties
        XCTAssertEqual(request1.paymentMethod?.id, "method_123")
        XCTAssertEqual(request1.paymentMethod?.type, AWXCardKey)
        XCTAssertNil(request1.paymentMethod?.card?.cvc)
        XCTAssertEqual(request1.intentId, mockPaymentIntent.id)
        XCTAssertNil(request1.paymentConsent)
        XCTAssertEqual(request1.consentOptions?["next_triggered_by"] as? String, "customer")
        
        // Test with CVC
        let request2 = provider.createPaymentRequestWithConsentCreation(
            methodId: "method_123",
            cvc: "123",
            consentOptions: PaymentConsentOptions(
                nextTriggeredBy: .merchantType,
                merchantTriggerReason: .unscheduled
            )
        )
        
        // Verify the request properties
        XCTAssertEqual(request2.paymentMethod?.id, "method_123")
        XCTAssertEqual(request2.paymentMethod?.type, AWXCardKey)
        XCTAssertEqual(request2.paymentMethod?.card?.cvc, "123")
        XCTAssertEqual(request2.intentId, mockPaymentIntent.id)
        XCTAssertNil(request2.paymentConsent)
        XCTAssertEqual(request2.consentOptions?["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(request2.consentOptions?["merchant_trigger_reason"] as? String, "unscheduled")
    }
}
