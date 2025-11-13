//
//  PaymentIntentProvider.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 6/11/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

/// A protocol for providing payment intents on-demand during the payment flow.
///
/// `PaymentIntentProvider` enables delayed payment intent creation, allowing you to defer
/// the creation of a payment intent until just before payment confirmation or when it is required.
///
/// ## Overview
///
/// When using `Session` with a payment intent provider instead of a pre-created intent,
/// the SDK will call `createPaymentIntent()` asynchronously when needed. The provider
/// must also supply the basic payment information (amount, currency, customerId) synchronously.
///
/// ## Usage Example
///
/// ```swift
/// class MyPaymentIntentProvider: NSObject, PaymentIntentProvider {
///     let amount: NSDecimalNumber = NSDecimalNumber(string: "99.99")
///     let currency: String = "USD"
///     let customerId: String? = "customer_123"
///
///     func createPaymentIntent() async throws -> AWXPaymentIntent {
///         // Call your backend to create the payment intent
///         let response = try await MyBackendAPI.createPaymentIntent(
///             amount: amount.decimalValue,
///             currency: currency,
///             customerId: customerId
///         )
///         return response.paymentIntent
///     }
/// }
///
/// // Use with Session
/// let provider = MyPaymentIntentProvider()
/// let session = Session(
///     paymentIntentProvider: provider,
///     countryCode: "US",
///     returnURL: "myapp://payment/return"
/// )
/// ```
///
/// ## Important Notes
///
/// - The `amount`, `currency` and `customerId` properties must return values immediately (they cannot be async)
/// - The values returned by `amount`, `currency` and `customerId` must match the values
///   in the `AWXPaymentIntent` returned by `createPaymentIntent()`
/// - The `amount` should be zero for recurring-only payments (no immediate charge)
/// - The `createPaymentIntent()` method will only be called once, and the result is cached
/// - If `createPaymentIntent()` throws an error, the payment flow will fail
///
/// - SeeAlso: `Session`, `AWXPaymentIntent`
@objc
public protocol PaymentIntentProvider {

    /// Creates a payment intent asynchronously.
    ///
    /// This method is called by the SDK when the payment intent is needed, typically just
    /// before payment confirmation. Implement this method to call your backend API and
    /// create a payment intent with the Airwallex API.
    ///
    /// ## Important
    ///
    /// The returned payment intent must have:
    /// - `amount` matching the `amount` property
    /// - `currency` matching the `currency` property
    /// - `customerId` matching the `customerId` property (if not nil)
    ///
    /// If these values don't match, the SDK will throw a validation error.
    ///
    /// - Returns: A fully initialized `AWXPaymentIntent` object
    /// - Throws: Any error that occurs during payment intent creation (e.g., network errors,
    ///          API errors). The error will be propagated to the payment flow.
    func createPaymentIntent() async throws -> AWXPaymentIntent

    /// The payment amount as an NSDecimalNumber value.
    ///
    /// This value must be available immediately and should match the amount
    /// of the payment intent that will be created by `createPaymentIntent()`.
    ///
    /// - Important: Should be zero for recurring-only payments (no immediate charge).
    ///             Must match the amount in the created payment intent.
    var amount: NSDecimalNumber { get }

    /// The three-letter ISO currency code (e.g., "USD", "AUD", "GBP").
    ///
    /// This value must be available immediately and should match the currency
    /// of the payment intent that will be created by `createPaymentIntent()`.
    ///
    /// - Important: Must be a valid ISO 4217 currency code.
    var currency: String { get }

    /// The customer ID associated with this payment, if available.
    ///
    /// This value must be available immediately. If not nil, it should match the
    /// customer ID of the payment intent that will be created by `createPaymentIntent()`.
    ///
    /// - Important: Required for recurring payments and saved payment methods.
    var customerId: String? { get }
}
