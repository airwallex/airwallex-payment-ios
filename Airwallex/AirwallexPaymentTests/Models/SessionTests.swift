
//
//  SessionTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
#if canImport(AirwallexPayment)
@testable @_spi(AWX) import AirwallexPayment
#endif
import AirwallexCore

final class SessionTests: XCTestCase {
    
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockCustomerId = "customer_id"
    private var mockClientSecret = "client_secret"
    private var mockIntentId = "intent_id"
    private var mockCountryCode = "AU"
    private var mockReturnURL = "https://airwallex.com/return"
    private var mockBillingContactFields: RequiredBillingContactFields = [.name, .address]
    private var mockPaymentMethods = [AWXCardKey, AWXWeChatPayKey]
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create a mock payment intent
        mockPaymentIntent = AWXPaymentIntent()
        mockPaymentIntent.customerId = mockCustomerId
        mockPaymentIntent.clientSecret = mockClientSecret
        mockPaymentIntent.id = mockIntentId
        mockPaymentIntent.amount = NSDecimalNumber(value: 100)
        mockPaymentIntent.currency = "AUD"
    }
    
    // MARK: - Initialization Tests
    
    func testInit_withDefaultParameters() {
        // Test initializing with default parameters
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )
        
        // Verify properties set from initializer
        XCTAssertEqual(session.paymentIntent, mockPaymentIntent)
        XCTAssertNil(session.paymentConsentOptions)
        XCTAssertTrue(session.autoCapture)
        XCTAssertTrue(session.autoSaveCardForFuturePayments)
        XCTAssertEqual(session.countryCode, mockCountryCode)
        XCTAssertEqual(session.returnURL, mockReturnURL)
        XCTAssertFalse(session.hidePaymentConsents)
        XCTAssertEqual(session.lang, Locale.current.languageCode ?? "en")
        XCTAssertEqual(session.requiredBillingContactFields, .name)
        XCTAssertNil(session.billing)
        XCTAssertNil(session.applePayOptions)
        XCTAssertNil(session.paymentMethods)
    }
    
    func testInit_withCustomParameters() {
        // Test initializing with custom parameters
        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()
        // Use the mockBillingContactFields for consistency
        
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            applePayOptions: applePayOptions,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            paymentConsentOptions: consentOptions,
            requiredBillingContactFields: mockBillingContactFields,
            returnURL: mockReturnURL
        )
        
        // Verify properties set from initializer
        XCTAssertEqual(session.paymentIntent, mockPaymentIntent)
        XCTAssertEqual(session.paymentConsentOptions?.nextTriggeredBy, consentOptions.nextTriggeredBy)
        XCTAssertEqual(session.paymentConsentOptions?.merchantTriggerReason, consentOptions.merchantTriggerReason)
        XCTAssertFalse(session.autoCapture)
        XCTAssertFalse(session.autoSaveCardForFuturePayments)
        XCTAssertEqual(session.countryCode, mockCountryCode)
        XCTAssertEqual(session.returnURL, mockReturnURL)
        XCTAssertTrue(session.hidePaymentConsents)
        XCTAssertEqual(session.lang, "zh-Hans")
        XCTAssertEqual(session.requiredBillingContactFields, mockBillingContactFields)
        XCTAssertEqual(session.billing, billing)
        XCTAssertEqual(session.applePayOptions, applePayOptions)
        XCTAssertEqual(session.paymentMethods, mockPaymentMethods)
    }
    
    // MARK: - PaymentIntentProvider Initialization Tests

    func testInit_withPaymentIntentProvider_defaultParameters() {
        // Create a mock payment intent provider
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        // Verify properties set from initializer
        XCTAssertNil(session.paymentIntent)
        XCTAssertNotNil(session.paymentIntentProvider)
        XCTAssertNil(session.paymentConsentOptions)
        XCTAssertTrue(session.autoCapture)
        XCTAssertTrue(session.autoSaveCardForFuturePayments)
        XCTAssertEqual(session.countryCode, mockCountryCode)
        XCTAssertEqual(session.returnURL, mockReturnURL)
        XCTAssertFalse(session.hidePaymentConsents)
        XCTAssertEqual(session.lang, Locale.current.languageCode ?? "en")
        XCTAssertEqual(session.requiredBillingContactFields, .name)
        XCTAssertNil(session.billing)
        XCTAssertNil(session.applePayOptions)
        XCTAssertNil(session.paymentMethods)
    }

    func testInit_withPaymentIntentProvider_customParameters() {
        // Create a mock payment intent provider
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            applePayOptions: applePayOptions,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            paymentConsentOptions: consentOptions,
            requiredBillingContactFields: mockBillingContactFields,
            returnURL: mockReturnURL
        )

        // Verify properties set from initializer
        XCTAssertNil(session.paymentIntent)
        XCTAssertNotNil(session.paymentIntentProvider)
        XCTAssertEqual(session.paymentConsentOptions?.nextTriggeredBy, consentOptions.nextTriggeredBy)
        XCTAssertEqual(session.paymentConsentOptions?.merchantTriggerReason, consentOptions.merchantTriggerReason)
        XCTAssertFalse(session.autoCapture)
        XCTAssertFalse(session.autoSaveCardForFuturePayments)
        XCTAssertEqual(session.countryCode, mockCountryCode)
        XCTAssertEqual(session.returnURL, mockReturnURL)
        XCTAssertTrue(session.hidePaymentConsents)
        XCTAssertEqual(session.lang, "zh-Hans")
        XCTAssertEqual(session.requiredBillingContactFields, mockBillingContactFields)
        XCTAssertEqual(session.billing, billing)
        XCTAssertEqual(session.applePayOptions, applePayOptions)
        XCTAssertEqual(session.paymentMethods, mockPaymentMethods)
    }

    // MARK: - Overridden Methods Tests

    func testCustomerId() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )
        
        XCTAssertEqual(session.customerId(), mockCustomerId)
        
        // Test when customerId is nil
        mockPaymentIntent.customerId = nil
        XCTAssertNil(session.customerId())
    }
    
    func testCurrency() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )
        
        XCTAssertEqual(session.currency(), "AUD")
    }
    
    func testAmount() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )
        
        XCTAssertEqual(session.amount(), mockPaymentIntent.amount)
    }
    
    func testPaymentIntentId() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )
        
        XCTAssertEqual(session.paymentIntentId(), mockIntentId)
    }
    
    func testTransactionMode_oneOff() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )
        
        XCTAssertEqual(session.transactionMode(), AWXPaymentTransactionModeOneOff)
    }
    
    func testTransactionMode_recurring() {
        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType)
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            paymentConsentOptions: consentOptions,
            returnURL: mockReturnURL
        )

        XCTAssertEqual(session.transactionMode(), AWXPaymentTransactionModeRecurring)
    }

    func testCustomerId_withProvider() {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        XCTAssertEqual(session.customerId(), mockCustomerId)

        // Test with nil customerId
        let providerWithoutCustomer = MockPaymentIntentProvider(
            customerId: nil,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let sessionWithoutCustomer = Session(
            paymentIntentProvider: providerWithoutCustomer,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        XCTAssertNil(sessionWithoutCustomer.customerId())
    }

    func testCurrency_withProvider() {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "USD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        XCTAssertEqual(session.currency(), "USD")
    }

    func testPaymentIntentId_withProvider() {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        // Should return nil before payment intent is created
        XCTAssertNil(session.paymentIntentId())
    }

    func testTransactionMode_withProvider_oneOff() {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        XCTAssertEqual(session.transactionMode(), AWXPaymentTransactionModeOneOff)
    }

    func testTransactionMode_withProvider_recurring() {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType)
        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            paymentConsentOptions: consentOptions,
            returnURL: mockReturnURL
        )

        XCTAssertEqual(session.transactionMode(), AWXPaymentTransactionModeRecurring)
    }

    // MARK: - EnsurePaymentIntent Tests

    func testEnsurePaymentIntent_withExistingIntent() async throws {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        // Should return existing intent without creating a new one
        let intent = try await session.ensurePaymentIntent()
        XCTAssertEqual(intent, mockPaymentIntent)
        XCTAssertEqual(intent.id, mockIntentId)
    }

    func testEnsurePaymentIntent_withProvider() async throws {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        // Verify no intent exists initially
        XCTAssertNil(session.paymentIntent)

        // Ensure payment intent - should create one from provider
        let intent = try await session.ensurePaymentIntent()
        XCTAssertNotNil(intent)
        XCTAssertEqual(intent.customerId, mockCustomerId)
        XCTAssertEqual(intent.currency, "AUD")
        XCTAssertEqual(intent.amount, NSDecimalNumber(value: 100))

        // Verify the intent is cached
        XCTAssertEqual(session.paymentIntent, intent)

        // Second call should return cached intent
        let cachedIntent = try await session.ensurePaymentIntent()
        XCTAssertEqual(cachedIntent, intent)
    }

    func testEnsurePaymentIntent_providerThrowsError() async {
        let provider = MockPaymentIntentProviderWithError()

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        do {
            _ = try await session.ensurePaymentIntent()
            XCTFail("Should throw error when provider fails")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testEnsurePaymentIntent_noIntentOrProvider() async {
        // Test line 216: When both paymentIntent and paymentIntentProvider are nil
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL
        )

        // Use reflection to set both paymentIntent and paymentIntentProvider to nil
        session.setValue(nil, forKey: "paymentIntent")
        session.setValue(nil, forKey: "paymentIntentProvider")

        do {
            _ = try await session.ensurePaymentIntent()
            XCTFail("Should throw error when both intent and provider are nil")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, AWXSDKErrorDomain)
            XCTAssertEqual(error.code, -1)
            XCTAssertEqual(
                error.userInfo[NSLocalizedDescriptionKey] as? String,
                "Payment intent not available. Either provide a payment intent or a payment intent provider."
            )
        }
    }

    // MARK: - Convenience Init Tests
    
    func testConvenienceInit_fromSameType() {
        // Setup with all properties configured
        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()
        
        let originalSession = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            applePayOptions: applePayOptions,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            paymentConsentOptions: consentOptions,
            requiredBillingContactFields: mockBillingContactFields,
            returnURL: mockReturnURL
        )
        
        let newSession = Session.convertFromLegacySession(originalSession)
        XCTAssertNotNil(newSession)
        
        // Verify all 12 properties are copied correctly
        // 1. countryCode
        XCTAssertEqual(newSession?.countryCode, originalSession.countryCode)
        // 2. paymentIntent
        XCTAssertEqual(newSession?.paymentIntent, originalSession.paymentIntent)
        // 3. returnURL
        XCTAssertEqual(newSession?.returnURL, originalSession.returnURL)
        // 4. applePayOptions
        XCTAssertEqual(newSession?.applePayOptions, originalSession.applePayOptions)
        // 5. autoCapture
        XCTAssertEqual(newSession?.autoCapture, originalSession.autoCapture)
        // 6. autoSaveCardForFuturePayments
        XCTAssertEqual(newSession?.autoSaveCardForFuturePayments, originalSession.autoSaveCardForFuturePayments)
        // 7. billing
        XCTAssertEqual(newSession?.billing, originalSession.billing)
        // 8. hidePaymentConsents
        XCTAssertEqual(newSession?.hidePaymentConsents, originalSession.hidePaymentConsents)
        // 9. lang
        XCTAssertEqual(newSession?.lang, originalSession.lang)
        // 10. paymentMethods
        XCTAssertEqual(newSession?.paymentMethods, originalSession.paymentMethods)
        // 11. consentOptions
        XCTAssertEqual(newSession?.paymentConsentOptions?.nextTriggeredBy, originalSession.paymentConsentOptions?.nextTriggeredBy)
        XCTAssertEqual(newSession?.paymentConsentOptions?.merchantTriggerReason, originalSession.paymentConsentOptions?.merchantTriggerReason)
        // 12. requiredBillingContactFields
        XCTAssertEqual(newSession?.requiredBillingContactFields, originalSession.requiredBillingContactFields)
    }
    
    func testConvenienceInit_fromOneOffSession() {
        let oneOffSession = AWXOneOffSession()
        // Set properties specific to AWXOneOffSession
        oneOffSession.paymentIntent = mockPaymentIntent
        oneOffSession.autoCapture = false
        oneOffSession.autoSaveCardForFuturePayments = false
        
        // Set properties inherited from AWXSession
        oneOffSession.countryCode = mockCountryCode
        oneOffSession.returnURL = mockReturnURL
        oneOffSession.hidePaymentConsents = true
        oneOffSession.lang = "zh-Hans"
        oneOffSession.applePayOptions = AWXApplePayOptions()
        oneOffSession.billing = AWXPlaceDetails()
        oneOffSession.paymentMethods = mockPaymentMethods
        oneOffSession.requiredBillingContactFields = mockBillingContactFields
        
        let session = Session.convertFromLegacySession(oneOffSession)
        XCTAssertNotNil(session)
        
        // Verify properties specific to AWXOneOffSession
        XCTAssertEqual(session?.paymentIntent, oneOffSession.paymentIntent)
        XCTAssertEqual(session?.autoCapture, oneOffSession.autoCapture)
        XCTAssertEqual(session?.autoSaveCardForFuturePayments, oneOffSession.autoSaveCardForFuturePayments)
        XCTAssertNil(session?.paymentConsentOptions)
        
        // Verify properties inherited from AWXSession
        XCTAssertEqual(session?.countryCode, oneOffSession.countryCode)
        XCTAssertEqual(session?.returnURL, oneOffSession.returnURL)
        XCTAssertEqual(session?.hidePaymentConsents, oneOffSession.hidePaymentConsents)
        XCTAssertEqual(session?.lang, oneOffSession.lang)
        XCTAssertEqual(session?.applePayOptions, oneOffSession.applePayOptions)
        XCTAssertEqual(session?.billing, oneOffSession.billing)
        XCTAssertEqual(session?.paymentMethods, oneOffSession.paymentMethods)
        XCTAssertEqual(session?.requiredBillingContactFields, oneOffSession.requiredBillingContactFields)
    }
    
    func testConvenienceInit_fromRecurringWithIntentSession() {
        let recurringSession = AWXRecurringWithIntentSession()
        // Set properties specific to AWXRecurringWithIntentSession
        recurringSession.paymentIntent = mockPaymentIntent
        recurringSession.autoCapture = false
        recurringSession.nextTriggerByType = .merchantType
        recurringSession.merchantTriggerReason = .scheduled
        
        // Set properties inherited from AWXSession
        recurringSession.countryCode = mockCountryCode
        recurringSession.returnURL = mockReturnURL
        recurringSession.hidePaymentConsents = true
        recurringSession.lang = "zh-Hans"
        recurringSession.applePayOptions = AWXApplePayOptions()
        recurringSession.billing = AWXPlaceDetails()
        recurringSession.paymentMethods = mockPaymentMethods
        recurringSession.requiredBillingContactFields = mockBillingContactFields
        
        let session = Session.convertFromLegacySession(recurringSession)
        XCTAssertNotNil(session)
        
        // Verify properties specific to AWXRecurringWithIntentSession
        XCTAssertEqual(session?.paymentIntent, recurringSession.paymentIntent)
        XCTAssertEqual(session?.autoCapture, recurringSession.autoCapture)
        
        // Verify recurring options
        XCTAssertNotNil(session?.paymentConsentOptions)
        XCTAssertEqual(session?.paymentConsentOptions?.nextTriggeredBy, recurringSession.nextTriggerByType)
        XCTAssertEqual(session?.paymentConsentOptions?.merchantTriggerReason, recurringSession.merchantTriggerReason)
        
        // Verify properties inherited from AWXSession
        XCTAssertEqual(session?.countryCode, recurringSession.countryCode)
        XCTAssertEqual(session?.returnURL, recurringSession.returnURL)
        XCTAssertEqual(session?.hidePaymentConsents, recurringSession.hidePaymentConsents)
        XCTAssertEqual(session?.lang, recurringSession.lang)
        XCTAssertEqual(session?.applePayOptions, recurringSession.applePayOptions)
        XCTAssertEqual(session?.billing, recurringSession.billing)
        XCTAssertEqual(session?.paymentMethods, recurringSession.paymentMethods)
        XCTAssertEqual(session?.requiredBillingContactFields, recurringSession.requiredBillingContactFields)
    }
    
    func testConvenienceInit_fromUnsupportedSessionType() {
        let baseSession = AWXSession()
        baseSession.countryCode = mockCountryCode
        baseSession.returnURL = mockReturnURL
        
        let session = Session.convertFromLegacySession(baseSession)
        XCTAssertNil(session, "Should return nil for unsupported session types")
    }
    
    func testConvenienceInit_withInvalidPaymentIntent() {
        let oneOffSession = AWXOneOffSession()
        oneOffSession.countryCode = mockCountryCode
        oneOffSession.returnURL = mockReturnURL
        
        // Test with nil payment intent
        oneOffSession.paymentIntent = nil
        XCTAssertNil(Session.convertFromLegacySession(oneOffSession), "Should return nil when payment intent is nil")
        
        // Test with empty currency
        let emptyIntent = AWXPaymentIntent()
        emptyIntent.id = mockIntentId
        emptyIntent.clientSecret = mockClientSecret
        emptyIntent.currency = ""
        oneOffSession.paymentIntent = emptyIntent
        XCTAssertNil(Session.convertFromLegacySession(oneOffSession), "Should return nil when currency is empty")
    }
    
    // MARK: - Convert to Legacy Session Tests
    
    func testConvertToLegacySession_oneOff() async throws {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            returnURL: mockReturnURL
        )
        
        let legacySession = try await session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXOneOffSession)
        
        let oneOffSession = legacySession as! AWXOneOffSession
        XCTAssertEqual(oneOffSession.countryCode, session.countryCode)
        XCTAssertEqual(oneOffSession.paymentIntent, session.paymentIntent)
        XCTAssertEqual(oneOffSession.returnURL, session.returnURL)
        XCTAssertEqual(oneOffSession.autoCapture, session.autoCapture)
        XCTAssertEqual(oneOffSession.autoSaveCardForFuturePayments, session.autoSaveCardForFuturePayments)
    }
    
    func testConvertToLegacySession_recurringWithIntent() async throws {
        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            autoCapture: false,
            paymentConsentOptions: consentOptions,
            returnURL: mockReturnURL
        )
        
        let legacySession = try await session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXRecurringWithIntentSession)
        
        let recurringSession = legacySession as! AWXRecurringWithIntentSession
        XCTAssertEqual(recurringSession.countryCode, session.countryCode)
        XCTAssertEqual(recurringSession.paymentIntent, session.paymentIntent)
        XCTAssertEqual(recurringSession.returnURL, session.returnURL)
        XCTAssertEqual(recurringSession.autoCapture, session.autoCapture)
        XCTAssertEqual(recurringSession.nextTriggerByType, consentOptions.nextTriggeredBy)
        XCTAssertEqual(recurringSession.merchantTriggerReason, consentOptions.merchantTriggerReason ?? .undefined)
    }
    
    func testConvertToLegacySession_recurringZeroAmount() async throws {
        // Create a zero-amount payment intent
        let zeroAmountIntent = AWXPaymentIntent()
        zeroAmountIntent.customerId = mockCustomerId
        zeroAmountIntent.clientSecret = mockClientSecret
        zeroAmountIntent.id = mockIntentId
        zeroAmountIntent.amount = NSDecimalNumber.zero
        zeroAmountIntent.currency = "AUD"
        
        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let session = Session(
            paymentIntent: zeroAmountIntent,
            countryCode: mockCountryCode,
            paymentConsentOptions: consentOptions,
            returnURL: mockReturnURL
        )
        
        let legacySession = try await session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXRecurringSession)
        
        let recurringSession = legacySession as! AWXRecurringSession
        XCTAssertEqual(recurringSession.countryCode, session.countryCode)
        XCTAssertEqual(recurringSession.returnURL, session.returnURL)
        XCTAssertEqual(recurringSession.currency(), session.currency())
        XCTAssertEqual(recurringSession.amount(), session.amount())
        XCTAssertEqual(recurringSession.customerId(), session.customerId())
        XCTAssertEqual(recurringSession.nextTriggerByType, consentOptions.nextTriggeredBy)
        XCTAssertEqual(recurringSession.merchantTriggerReason, consentOptions.merchantTriggerReason ?? .undefined)
    }
    
    // MARK: - Convert to Legacy Session with Provider Tests

    func testConvertToLegacySession_withProvider_oneOff() async throws {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            returnURL: mockReturnURL
        )

        let legacySession = try await session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXOneOffSession)

        let oneOffSession = legacySession as! AWXOneOffSession
        XCTAssertEqual(oneOffSession.countryCode, session.countryCode)
        XCTAssertNotNil(oneOffSession.paymentIntent)
        XCTAssertEqual(oneOffSession.paymentIntent?.customerId, mockCustomerId)
        XCTAssertEqual(oneOffSession.returnURL, session.returnURL)
        XCTAssertEqual(oneOffSession.autoCapture, session.autoCapture)
        XCTAssertEqual(oneOffSession.autoSaveCardForFuturePayments, session.autoSaveCardForFuturePayments)

        // Verify payment intent was created and cached
        XCTAssertNotNil(session.paymentIntent)
        XCTAssertEqual(session.paymentIntent?.customerId, mockCustomerId)
    }

    func testConvertToLegacySession_withProvider_recurringWithIntent() async throws {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber(value: 100)
        )

        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            autoCapture: false,
            paymentConsentOptions: consentOptions,
            returnURL: mockReturnURL
        )

        let legacySession = try await session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXRecurringWithIntentSession)

        let recurringSession = legacySession as! AWXRecurringWithIntentSession
        XCTAssertEqual(recurringSession.countryCode, session.countryCode)
        XCTAssertNotNil(recurringSession.paymentIntent)
        XCTAssertEqual(recurringSession.paymentIntent?.customerId, mockCustomerId)
        XCTAssertEqual(recurringSession.returnURL, session.returnURL)
        XCTAssertEqual(recurringSession.autoCapture, session.autoCapture)
        XCTAssertEqual(recurringSession.nextTriggerByType, consentOptions.nextTriggeredBy)
        XCTAssertEqual(recurringSession.merchantTriggerReason, consentOptions.merchantTriggerReason ?? .undefined)

        // Verify payment intent was created and cached
        XCTAssertNotNil(session.paymentIntent)
    }

    func testConvertToLegacySession_withProvider_recurringZeroAmount() async throws {
        let provider = MockPaymentIntentProvider(
            customerId: mockCustomerId,
            currency: "AUD",
            amount: NSDecimalNumber.zero
        )

        let consentOptions = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let session = Session(
            paymentIntentProvider: provider,
            countryCode: mockCountryCode,
            paymentConsentOptions: consentOptions,
            returnURL: mockReturnURL
        )

        let legacySession = try await session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXRecurringSession)

        let recurringSession = legacySession as! AWXRecurringSession
        XCTAssertEqual(recurringSession.countryCode, session.countryCode)
        XCTAssertEqual(recurringSession.returnURL, session.returnURL)
        XCTAssertEqual(recurringSession.currency(), "AUD")
        XCTAssertEqual(recurringSession.amount(), NSDecimalNumber.zero)
        XCTAssertEqual(recurringSession.customerId(), mockCustomerId)
        XCTAssertEqual(recurringSession.nextTriggerByType, consentOptions.nextTriggeredBy)
        XCTAssertEqual(recurringSession.merchantTriggerReason, consentOptions.merchantTriggerReason)

        // Verify payment intent was created
        XCTAssertNotNil(session.paymentIntent)
    }

    // MARK: - Common Configuration Tests

    func testConfigureCommonProperties() async throws {
        // This test indirectly tests the configureCommonProperties method through convertToLegacySession
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()
        // Use the mockBillingContactFields for consistency
        
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            applePayOptions: applePayOptions,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            requiredBillingContactFields: mockBillingContactFields,
            returnURL: mockReturnURL
        )
        
        let legacySession = try await session.convertToLegacySession()
        
        // Verify common properties were configured correctly
        XCTAssertEqual(legacySession.countryCode, session.countryCode)
        XCTAssertEqual(legacySession.returnURL, session.returnURL)
        XCTAssertEqual(legacySession.applePayOptions, session.applePayOptions)
        XCTAssertEqual(legacySession.billing, session.billing)
        XCTAssertEqual(legacySession.hidePaymentConsents, session.hidePaymentConsents)
        XCTAssertEqual(legacySession.lang, session.lang)
        XCTAssertEqual(legacySession.paymentMethods, session.paymentMethods)
        XCTAssertEqual(legacySession.requiredBillingContactFields, session.requiredBillingContactFields)
    }
}
