//
//  RecurringOptions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/8/18.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

/// `Session` is a Swift wrapper for AWXSession and its subclasses.
/// This class includes all properties from AWXSession, AWXOneOffSession, and AWXRecurringWithIntentSession.
@objc public final class Session: AWXSession {
    
    /// The payment intent to handle.
    public let paymentIntent: AWXPaymentIntent
    
    /// Required for recurring payment
    public internal(set) var recurringOptions: RecurringOptions?
    
    /// Only applicable when payment_method.type is card. If true the payment will be captured immediately after authorization succeeds.
    /// Default: YES
    public let autoCapture: Bool

    /// Whether show stored card.
    public let hidePaymentConsents: Bool

    /// Indicates whether card saving is enabled by default.
    /// Defaults to YES.
    public let autoSaveCardForFuturePayments: Bool
    
    /// Initialize a new Session
    /// - Parameters:
    ///   - countryCode: The country code
    ///   - paymentIntent: The payment intent to handle
    ///   - returnURL: Return URL for redirects
    ///   - applePayOptions: Apple Pay options (optional)
    ///   - autoCapture: Whether to capture payment immediately after authorization (default: true)
    ///   - autoSaveCardForFuturePayments: Whether to save card for future payments (default: true)
    ///   - billing: The billing address (optional)
    ///   - hidePaymentConsents: Whether to hide stored payment methods (default: false)
    ///   - lang: The language code (default: system language)
    ///   - paymentMethods: Array of payment method type names to limit displayed methods (optional)
    ///   - recurringOptions: Options for recurring payments (optional)
    ///   - requiredBillingContactFields: Required billing contact fields (default: .name)
    public init(countryCode: String,
         paymentIntent: AWXPaymentIntent,
         returnURL: String,
         applePayOptions: AWXApplePayOptions? = nil,
         autoCapture: Bool = true,
         autoSaveCardForFuturePayments: Bool = true,
         billing: AWXPlaceDetails? = nil,
         hidePaymentConsents: Bool = false,
         lang: String = Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "en",
         paymentMethods: [String]? = nil,
         recurringOptions: RecurringOptions? = nil,
         requiredBillingContactFields: RequiredBillingContactFields = .name
    ) {
        self.paymentIntent = paymentIntent
        self.recurringOptions = recurringOptions
        self.autoCapture = autoCapture
        self.hidePaymentConsents = hidePaymentConsents
        self.autoSaveCardForFuturePayments = autoSaveCardForFuturePayments
        
        super.init()
        self.countryCode = countryCode
        self.returnURL = returnURL
        self.lang = lang
        self.billing = billing
        self.requiredBillingContactFields = requiredBillingContactFields
        self.applePayOptions = applePayOptions
        self.paymentMethods = paymentMethods
    }
    
    public override func customerId() -> String? {
        paymentIntent.customerId
    }
    
    public override func currency() -> String {
        paymentIntent.currency
    }
    
    public override func amount() -> NSDecimalNumber {
        paymentIntent.amount
    }
    
    public override func paymentIntentId() -> String? {
        paymentIntent.id
    }
    
    public override func validateData() -> String? {
        return nil
    }
    
    public override func transactionMode() -> String {
        recurringOptions == nil ? AWXPaymentTransactionModeOneOff: AWXPaymentTransactionModeRecurring
    }
}

// MARK: -

extension Session {
    /// Initialize a new Session from an AWXOneOffSession
    /// - Parameter oneOffSession: The AWXOneOffSession to initialize from
    @objc public convenience init(oneOffSession: AWXOneOffSession) {
        self.init(
            countryCode: oneOffSession.countryCode,
            paymentIntent: oneOffSession.paymentIntent!,// TODO: try to avoid force unwrap here
            returnURL: oneOffSession.returnURL,
            applePayOptions: oneOffSession.applePayOptions,
            autoCapture: oneOffSession.autoCapture,
            autoSaveCardForFuturePayments: oneOffSession.autoSaveCardForFuturePayments,
            billing: oneOffSession.billing,
            hidePaymentConsents: oneOffSession.hidePaymentConsents,
            lang: oneOffSession.lang ?? Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "en",
            paymentMethods: oneOffSession.paymentMethods,
            recurringOptions: nil,
            requiredBillingContactFields: oneOffSession.requiredBillingContactFields
        )
    }
    
    /// Initialize a new Session from an AWXRecurringWithIntentSession
    /// - Parameter recurringWithIntentSession: The AWXRecurringWithIntentSession to initialize from
    @objc public convenience init(recurringWithIntentSession: AWXRecurringWithIntentSession) {
        self.init(
            countryCode: recurringWithIntentSession.countryCode,
            paymentIntent: recurringWithIntentSession.paymentIntent!,
            returnURL: recurringWithIntentSession.returnURL,
            applePayOptions: recurringWithIntentSession.applePayOptions,
            autoCapture: recurringWithIntentSession.autoCapture,
            billing: recurringWithIntentSession.billing,
            hidePaymentConsents: true,
            lang: recurringWithIntentSession.lang ?? Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "en",
            paymentMethods: recurringWithIntentSession.paymentMethods,
            recurringOptions: RecurringOptions(
                nextTriggeredBy: recurringWithIntentSession.nextTriggerByType,
                merchantTriggerReason: recurringWithIntentSession.merchantTriggerReason
            ),
            requiredBillingContactFields: recurringWithIntentSession.requiredBillingContactFields
        )
    }
}
