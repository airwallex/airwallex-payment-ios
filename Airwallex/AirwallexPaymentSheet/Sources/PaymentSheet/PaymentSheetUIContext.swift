//
//  PaymentSheetUIContext.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

/// Payment UI context for payment sheet with additional configuration options.
///
/// This subclass extends `PaymentUIContext` with layout configuration
/// and other payment sheet-specific settings.
@MainActor
class PaymentSheetUIContext: PaymentUIContext {

    /// The layout style for payment UI sections.
    var layout: AWXUIContext.PaymentLayout = .tab

    /// Whether this context is for an embedded payment element.
    /// When true, section controllers should use zero horizontal insets.
    var isEmbedded: Bool { paymentElement != nil }

    /// Whether Apple Pay pinned at top.
    var showsApplePayAsPrimaryButton: Bool = true

    /// The current payment method name being processed (for delegate callbacks).
    var currentPaymentMethod: String?

    /// Weak reference to the payment element for delegate callbacks (embedded only).
    weak var paymentElement: AWXPaymentElement?

    /// Shared image loader for payment method icons.
    private(set) lazy var imageLoader = ImageLoader()

    /// Factory for creating payment session handlers.
    /// Can be replaced with a mock factory for testing.
    lazy var paymentSessionHandlerFactory: PaymentSessionHandlerFactory = DefaultPaymentSessionHandlerFactory()
}

// MARK: - PaymentSectionController Protocol

/// Protocol for section controllers that handle payment checkout.
/// Provides a helper method to prepare for embedded checkout with proper loading indicator handling.
@MainActor
protocol PaymentSectionController: SectionController where SectionType == PaymentSectionType, ItemType == String {
    var paymentUIContext: PaymentSheetUIContext { get }
}

extension PaymentSectionController {
    /// Prepares the UI context for embedded checkout and handles loading indicator display.
    ///
    /// Call this method at the start of checkout when in embedded mode. It:
    /// - Sets the current payment method name for delegate callbacks
    /// - Disables the handler's built-in loading indicator
    /// - Notifies the delegate of processing state change
    /// - Falls back to section-level loading indicator if delegate doesn't handle it
    ///
    /// - Parameters:
    ///   - paymentMethod: The name of the payment method being processed.
    ///   - handler: The payment session handler (to disable its loading indicator).
    func prepareForEmbeddedCheckout(paymentMethod: String, handler: PaymentSessionHandlerProtocol?) {
        guard paymentUIContext.isEmbedded else { return }

        paymentUIContext.currentPaymentMethod = paymentMethod
        handler?.showIndicator = false

        if let element = paymentUIContext.paymentElement,
           !element.notifyProcessingStateChanged(for: paymentMethod, isProcessing: true) {
            // Delegate didn't handle it, use default loading indicator
            context.startLoading(for: section)
        }
    }
}
