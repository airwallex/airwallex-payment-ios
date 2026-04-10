//
//  PaymentSessionHandlerFactory.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/2/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

/// Protocol that abstracts the payment session handler methods used by section controllers.
/// This allows for easier unit testing by enabling mock implementations.
@MainActor
protocol PaymentSessionHandlerProtocol: AnyObject {
    /// Whether to display the default loading indicator.
    /// Set to false if you prefer to display your own indicator.
    var showIndicator: Bool { get set }

    /// Initiates a card payment transaction.
    /// - Parameters:
    ///   - card: The card details required for processing the payment.
    ///   - billing: Billing information for the transaction.
    ///   - saveCard: Whether to save the card for future transactions.
    func confirmCardPayment(with card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool)

    /// Initiates a consent-based payment.
    /// - Parameter consent: The payment consent authorizing this transaction.
    func confirmConsentPayment(with consent: AWXPaymentConsent)

    /// Initiates an Apple Pay transaction.
    func confirmApplePay()

    /// Initiates a schema-based redirect payment.
    /// - Parameter paymentMethod: The payment method with all required information.
    func confirmRedirectPayment(with paymentMethod: AWXPaymentMethod) async
}

// MARK: - PaymentSessionHandler Conformance

extension PaymentSessionHandler: PaymentSessionHandlerProtocol {}

// MARK: - Factory Protocol

/// Factory protocol for creating payment session handlers.
/// Inject a mock factory in tests to verify payment flow behavior.
@MainActor
protocol PaymentSessionHandlerFactory {
    /// Creates a new payment session handler.
    /// - Parameters:
    ///   - session: The payment session.
    ///   - methodType: The payment method type (optional).
    ///   - paymentUIContext: The UI context for the payment flow.
    /// - Returns: A new payment session handler instance.
    func createHandler(
        session: AWXSession,
        methodType: AWXPaymentMethodType?,
        paymentUIContext: any PaymentUIContextProviding
    ) -> PaymentSessionHandlerProtocol
}

// MARK: - Default Factory Implementation

/// Default factory that creates real `PaymentSessionHandler` instances.
@MainActor
final class DefaultPaymentSessionHandlerFactory: PaymentSessionHandlerFactory {
    func createHandler(
        session: AWXSession,
        methodType: AWXPaymentMethodType?,
        paymentUIContext: any PaymentUIContextProviding
    ) -> PaymentSessionHandlerProtocol {
        PaymentSessionHandler(
            session: session,
            methodType: methodType,
            paymentUIContext: paymentUIContext
        )
    }
}
