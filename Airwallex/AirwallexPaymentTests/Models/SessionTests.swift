
//
//  SessionTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/8/29.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import AirwallexPayment
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
        XCTAssertNil(session.recurringOptions)
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
        let recurringOptions = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()
        // Use the mockBillingContactFields for consistency
        
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            applePayOptions: applePayOptions,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            recurringOptions: recurringOptions,
            requiredBillingContactFields: mockBillingContactFields
        )
        
        // Verify properties set from initializer
        XCTAssertEqual(session.paymentIntent, mockPaymentIntent)
        XCTAssertEqual(session.recurringOptions?.nextTriggeredBy, recurringOptions.nextTriggeredBy)
        XCTAssertEqual(session.recurringOptions?.merchantTriggerReason, recurringOptions.merchantTriggerReason)
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
        let recurringOptions = RecurringOptions(nextTriggeredBy: .merchantType)
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            recurringOptions: recurringOptions
        )
        
        XCTAssertEqual(session.transactionMode(), AWXPaymentTransactionModeRecurring)
    }
    
    // MARK: - Convenience Init Tests
    
    func testConvenienceInit_fromSameType() {
        // Setup with all properties configured
        let recurringOptions = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()
        
        let originalSession = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            applePayOptions: applePayOptions,
            autoCapture: false,
            autoSaveCardForFuturePayments: false,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            recurringOptions: recurringOptions,
            requiredBillingContactFields: mockBillingContactFields
        )
        
        let newSession = Session(originalSession)
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
        // 11. recurringOptions
        XCTAssertEqual(newSession?.recurringOptions?.nextTriggeredBy, originalSession.recurringOptions?.nextTriggeredBy)
        XCTAssertEqual(newSession?.recurringOptions?.merchantTriggerReason, originalSession.recurringOptions?.merchantTriggerReason)
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
        
        let session = Session(oneOffSession)
        XCTAssertNotNil(session)
        
        // Verify properties specific to AWXOneOffSession
        XCTAssertEqual(session?.paymentIntent, oneOffSession.paymentIntent)
        XCTAssertEqual(session?.autoCapture, oneOffSession.autoCapture)
        XCTAssertEqual(session?.autoSaveCardForFuturePayments, oneOffSession.autoSaveCardForFuturePayments)
        XCTAssertNil(session?.recurringOptions)
        
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
        
        let session = Session(recurringSession)
        XCTAssertNotNil(session)
        
        // Verify properties specific to AWXRecurringWithIntentSession
        XCTAssertEqual(session?.paymentIntent, recurringSession.paymentIntent)
        XCTAssertEqual(session?.autoCapture, recurringSession.autoCapture)
        
        // Verify recurring options
        XCTAssertNotNil(session?.recurringOptions)
        XCTAssertEqual(session?.recurringOptions?.nextTriggeredBy, recurringSession.nextTriggerByType)
        XCTAssertEqual(session?.recurringOptions?.merchantTriggerReason, recurringSession.merchantTriggerReason)
        
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
        
        let session = Session(baseSession)
        XCTAssertNil(session, "Should return nil for unsupported session types")
    }
    
    func testConvenienceInit_withInvalidPaymentIntent() {
        let oneOffSession = AWXOneOffSession()
        oneOffSession.countryCode = mockCountryCode
        oneOffSession.returnURL = mockReturnURL
        
        // Test with nil payment intent
        oneOffSession.paymentIntent = nil
        XCTAssertNil(Session(oneOffSession), "Should return nil when payment intent is nil")
        
        // Test with empty currency
        let emptyIntent = AWXPaymentIntent()
        emptyIntent.id = mockIntentId
        emptyIntent.clientSecret = mockClientSecret
        emptyIntent.currency = ""
        oneOffSession.paymentIntent = emptyIntent
        XCTAssertNil(Session(oneOffSession), "Should return nil when currency is empty")
    }
    
    // MARK: - Convert to Legacy Session Tests
    
    func testConvertToLegacySession_oneOff() {
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            autoCapture: false,
            autoSaveCardForFuturePayments: false
        )
        
        let legacySession = session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXOneOffSession)
        
        let oneOffSession = legacySession as! AWXOneOffSession
        XCTAssertEqual(oneOffSession.countryCode, session.countryCode)
        XCTAssertEqual(oneOffSession.paymentIntent, session.paymentIntent)
        XCTAssertEqual(oneOffSession.returnURL, session.returnURL)
        XCTAssertEqual(oneOffSession.autoCapture, session.autoCapture)
        XCTAssertEqual(oneOffSession.autoSaveCardForFuturePayments, session.autoSaveCardForFuturePayments)
    }
    
    func testConvertToLegacySession_recurringWithIntent() {
        let recurringOptions = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            autoCapture: false,
            recurringOptions: recurringOptions
        )
        
        let legacySession = session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXRecurringWithIntentSession)
        
        let recurringSession = legacySession as! AWXRecurringWithIntentSession
        XCTAssertEqual(recurringSession.countryCode, session.countryCode)
        XCTAssertEqual(recurringSession.paymentIntent, session.paymentIntent)
        XCTAssertEqual(recurringSession.returnURL, session.returnURL)
        XCTAssertEqual(recurringSession.autoCapture, session.autoCapture)
        XCTAssertEqual(recurringSession.nextTriggerByType, recurringOptions.nextTriggeredBy)
        XCTAssertEqual(recurringSession.merchantTriggerReason, recurringOptions.merchantTriggerReason ?? .undefined)
    }
    
    func testConvertToLegacySession_recurringZeroAmount() {
        // Create a zero-amount payment intent
        let zeroAmountIntent = AWXPaymentIntent()
        zeroAmountIntent.customerId = mockCustomerId
        zeroAmountIntent.clientSecret = mockClientSecret
        zeroAmountIntent.id = mockIntentId
        zeroAmountIntent.amount = NSDecimalNumber.zero
        zeroAmountIntent.currency = "AUD"
        
        let recurringOptions = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let session = Session(
            paymentIntent: zeroAmountIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            recurringOptions: recurringOptions
        )
        
        let legacySession = session.convertToLegacySession()
        XCTAssertTrue(legacySession is AWXRecurringSession)
        
        let recurringSession = legacySession as! AWXRecurringSession
        XCTAssertEqual(recurringSession.countryCode, session.countryCode)
        XCTAssertEqual(recurringSession.returnURL, session.returnURL)
        XCTAssertEqual(recurringSession.currency(), session.currency())
        XCTAssertEqual(recurringSession.amount(), session.amount())
        XCTAssertEqual(recurringSession.customerId(), session.customerId())
        XCTAssertEqual(recurringSession.nextTriggerByType, recurringOptions.nextTriggeredBy)
        XCTAssertEqual(recurringSession.merchantTriggerReason, recurringOptions.merchantTriggerReason ?? .undefined)
    }
    
    // MARK: - Common Configuration Tests
    
    func testConfigureCommonProperties() {
        // This test indirectly tests the configureCommonProperties method through convertToLegacySession
        let applePayOptions = AWXApplePayOptions()
        let billing = AWXPlaceDetails()
        // Use the mockBillingContactFields for consistency
        
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: mockCountryCode,
            returnURL: mockReturnURL,
            applePayOptions: applePayOptions,
            billing: billing,
            hidePaymentConsents: true,
            lang: "zh-Hans",
            paymentMethods: mockPaymentMethods,
            requiredBillingContactFields: mockBillingContactFields
        )
        
        let legacySession = session.convertToLegacySession()
        
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
