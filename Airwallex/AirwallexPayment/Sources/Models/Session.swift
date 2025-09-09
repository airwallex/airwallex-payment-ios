//
//  Session.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/8/18.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

/// `Session` is a specialized subclass of `AWXSession`
///
/// This class provides a unified interface for working with the simplified consent flow,
/// abstracting away the complexity of different payment scenarios (one-off and recurring payments).
/// It handles both standard payment intents and recurring payment configurations through a
/// consistent API, making it easier to implement payment processing in your application.
///
/// - SeeAlso: `AWXSession`, `PaymentConsentOptions`
@objc public final class Session: AWXSession {
    
    /// The payment intent to handle.
    @objc public let paymentIntent: AWXPaymentIntent
    
    /// Required for recurring payment
    @objc public let paymentConsentOptions: PaymentConsentOptions?
    
    /// Only applicable when payment_method.type is card. If true the payment will be captured immediately after authorization succeeds.
    /// Default: YES
    @objc public let autoCapture: Bool

    /// Indicates whether card saving is enabled by default.
    /// Defaults to YES.
    @objc public let autoSaveCardForFuturePayments: Bool
    
    /// Initialize a new Session
    /// - Parameters:
    ///   - paymentIntent: The payment intent to handle
    ///   - countryCode: The country code
    ///   - returnURL: Return URL for redirects
    ///   - applePayOptions: Apple Pay options (optional)
    ///   - autoCapture: Whether to capture payment immediately after authorization (default: true)
    ///   - autoSaveCardForFuturePayments: Whether to save card for future payments (default: true)
    ///   - billing: The billing address (optional)
    ///   - hidePaymentConsents: Whether to hide stored payment methods (default: false)
    ///   - lang: The language code (default: system language)
    ///   - paymentMethods: Array of payment method type names to limit displayed methods (optional)
    ///   - paymentConsentOptions: Options for recurring payments (optional)
    ///   - requiredBillingContactFields: Required billing contact fields (default: .name)
    @objc public init(paymentIntent: AWXPaymentIntent,
                      countryCode: String,
                      returnURL: String,
                      applePayOptions: AWXApplePayOptions? = nil,
                      autoCapture: Bool = true,
                      autoSaveCardForFuturePayments: Bool = true,
                      billing: AWXPlaceDetails? = nil,
                      hidePaymentConsents: Bool = false,
                      lang: String? = nil,
                      paymentMethods: [String]? = nil,
                      paymentConsentOptions: PaymentConsentOptions? = nil,
                      requiredBillingContactFields: RequiredBillingContactFields = .name
    ) {
        self.paymentIntent = paymentIntent
        self.paymentConsentOptions = paymentConsentOptions
        self.autoCapture = autoCapture
        self.autoSaveCardForFuturePayments = autoSaveCardForFuturePayments
        
        super.init()
        self.countryCode = countryCode
        self.hidePaymentConsents = hidePaymentConsents
        self.returnURL = returnURL
        self.lang = lang ?? Locale.current.languageCode ?? "en"
        self.billing = billing
        self.requiredBillingContactFields = requiredBillingContactFields
        self.applePayOptions = applePayOptions
        self.paymentMethods = paymentMethods
    }
    
    /// Returns the customer ID associated with the current payment intent.
    /// - Returns: The customer ID as a String, or nil if not available.
    @objc public override func customerId() -> String? {
        paymentIntent.customerId
    }
    
    /// Returns the currency code for the current payment.
    /// - Returns: The three-letter currency code as a String.
    @objc public override func currency() -> String {
        paymentIntent.currency
    }
    
    /// Returns the payment amount.
    /// - Returns: The payment amount as an NSDecimalNumber.
    @objc public override func amount() -> NSDecimalNumber {
        paymentIntent.amount
    }
    
    /// Returns the payment intent ID.
    /// - Returns: The payment intent ID as a String, or nil if not available.
    @objc public override func paymentIntentId() -> String? {
        paymentIntent.id
    }
    
    /// Determines the transaction mode based on the presence of recurring options.
    /// - Returns: "RECURRING" for recurring payments, "ONE_OFF" for one-time payments.
    /// - Complexity: O(1)
    @objc public override func transactionMode() -> String {
        return paymentConsentOptions == nil ? AWXPaymentTransactionModeOneOff : AWXPaymentTransactionModeRecurring
    }
}

// MARK: - Extensions

extension Session {
    
    /// Creates a new Session instance from an existing AWXSession.
    ///
    /// This initializer provides conversion capabilities from legacy session types
    /// to the unified Session class. It extracts all relevant properties from the source
    /// session and constructs a new Session instance with equivalent configuration.
    ///
    /// - Parameter session: The source AWXSession to convert from
    /// - Returns: A new Session instance, or nil if conversion is not possible
    convenience init?(_ session: AWXSession) {
        // Fast path for same type conversion
        if let existingSession = session as? Session {
            self.init(
                paymentIntent: existingSession.paymentIntent,
                countryCode: existingSession.countryCode,
                returnURL: existingSession.returnURL,
                applePayOptions: existingSession.applePayOptions,
                autoCapture: existingSession.autoCapture,
                autoSaveCardForFuturePayments: existingSession.autoSaveCardForFuturePayments,
                billing: existingSession.billing,
                hidePaymentConsents: existingSession.hidePaymentConsents,
                lang: existingSession.lang,
                paymentMethods: existingSession.paymentMethods,
                paymentConsentOptions: existingSession.paymentConsentOptions,
                requiredBillingContactFields: existingSession.requiredBillingContactFields
            )
            return
        }
        
        // Extract parameters from other session types
        var intent: AWXPaymentIntent?
        var consentOptions: PaymentConsentOptions?
        var autoCapture = false
        var autoSaveCard = true
        
        switch session {
        case let oneOffSession as AWXOneOffSession:
            intent = oneOffSession.paymentIntent
            consentOptions = nil
            autoCapture = oneOffSession.autoCapture
            autoSaveCard = oneOffSession.autoSaveCardForFuturePayments
            
        case let recurringSession as AWXRecurringWithIntentSession:
            intent = recurringSession.paymentIntent
            autoCapture = recurringSession.autoCapture
            consentOptions = PaymentConsentOptions(
                nextTriggeredBy: recurringSession.nextTriggerByType,
                merchantTriggerReason: recurringSession.merchantTriggerReason
            )
            
        default:
            // Unsupported session type
            return nil
        }
        
        // Validate required parameters
        guard let intent, !intent.currency.isEmpty else {
            // Cannot create a Session without a valid payment intent
            return nil
        }
        
        // Create new instance with extracted parameters
        self.init(
            paymentIntent: intent,
            countryCode: session.countryCode,
            returnURL: session.returnURL,
            applePayOptions: session.applePayOptions,
            autoCapture: autoCapture,
            autoSaveCardForFuturePayments: autoSaveCard,
            billing: session.billing,
            hidePaymentConsents: session.hidePaymentConsents,
            lang: session.lang,
            paymentMethods: session.paymentMethods,
            paymentConsentOptions: consentOptions,
            requiredBillingContactFields: session.requiredBillingContactFields
        )
    }
    
    /// Converts the current `Session` instance to a legacy `AWXSession` object.
    ///
    /// - Note: This conversion is primarily required for Local Payment Methods (LPM),
    ///   as they are not yet supported by the simplified consent flow.
    ///
    /// - Returns: A legacy `AWXSession` object representing the current session state.
    func convertToLegacySession() -> AWXSession {
        if let paymentConsentOptions {
            if paymentIntent.amount == 0 {
                // Zero-amount recurring session (setup only)
                let session = AWXRecurringSession()
                configureCommonProperties(for: session)
                
                // Set specific properties for recurring sessions
                session.setAmount(paymentIntent.amount)
                session.setCurrency(paymentIntent.currency)
                session.setCustomerId(paymentIntent.customerId)
                session.merchantTriggerReason = paymentConsentOptions.merchantTriggerReason ?? .undefined
                session.nextTriggerByType = paymentConsentOptions.nextTriggeredBy
                
                return session
            } else {
                // Non-zero amount recurring session with intent
                let session = AWXRecurringWithIntentSession()
                configureCommonProperties(for: session)
                
                // Set specific properties for recurring with intent
                session.autoCapture = autoCapture
                session.paymentIntent = paymentIntent
                session.merchantTriggerReason = paymentConsentOptions.merchantTriggerReason ?? .undefined
                session.nextTriggerByType = paymentConsentOptions.nextTriggeredBy
                
                return session
            }
        } else {
            // One-off payment session
            let session = AWXOneOffSession()
            configureCommonProperties(for: session)
            
            // Set specific properties for one-off payments
            session.autoCapture = autoCapture
            session.autoSaveCardForFuturePayments = autoSaveCardForFuturePayments
            session.paymentIntent = paymentIntent
            
            return session
        }
    }
    
    /// Helper method to configure common properties for all session types.
    ///
    /// - Parameter session: The AWXSession object to configure
    private func configureCommonProperties(for session: AWXSession) {
        session.applePayOptions = applePayOptions
        session.billing = billing
        session.countryCode = countryCode
        session.hidePaymentConsents = hidePaymentConsents
        session.lang = lang
        session.paymentMethods = paymentMethods
        session.requiredBillingContactFields = requiredBillingContactFields
        session.returnURL = returnURL
    }
}
