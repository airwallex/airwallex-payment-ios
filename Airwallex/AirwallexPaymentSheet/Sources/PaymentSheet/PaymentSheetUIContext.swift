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

@MainActor
class PaymentSheetUIContext: PaymentUIContextProviding {

    // MARK: - PaymentUIContextProviding

    weak var viewController: UIViewController?
    weak var delegate: AWXPaymentResultDelegate?

    /// Conforms to `PaymentUIContextProviding` and adds layout configuration
    /// and other payment sheet-specific settings.
    /// A block type for dismissing the payment UI.
    /// The block takes a completion handler that should be called after dismissal is complete.
    typealias DismissActionBlock = (@escaping () -> Void) -> Void
    var dismissAction: DismissActionBlock?

    var hasPaymentUI: Bool { true }

    init(delegate: AWXPaymentResultDelegate? = nil) {
        self.delegate = delegate
    }

    func completePaymentSession() async {
        await withCheckedContinuation { continuation in
            guard let dismissAction else {
                continuation.resume()
                return
            }
            dismissAction {
                continuation.resume()
            }
            self.dismissAction = nil
        }
    }

    // MARK: - Sheet-specific

    /// The layout style for payment UI sections.
    var layout: AWXUIContext.PaymentLayout = .tab

    /// Whether this context is for an embedded payment element.
    /// When true, section controllers should use zero horizontal insets.
    var isEmbedded: Bool { paymentElement != nil }

    /// Configuration for the Apple Pay button.
    var applePayButtonConfiguration = AWXPaymentElement.ApplePayButton()

    /// Configuration for the checkout button.
    var checkoutButtonConfiguration = AWXPaymentElement.CheckoutButton()

    /// Whether Apple Pay pinned at top.
    var showsApplePayAsPrimaryButton: Bool {
        applePayButtonConfiguration.showsAsPrimaryButton
    }

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
    var session: AWXSession { get }
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
    /// The checkout button title, using the custom title from configuration if set,
    /// or falling back to the session-based default ("Pay" or "Confirm").
    var checkoutButtonTitle: String {
        paymentUIContext.checkoutButtonConfiguration.title
            ?? (session.shouldShowPayAsCta
                ? NSLocalizedString("Pay", bundle: .paymentSheet, comment: "checkout button title for one-off payment")
                : NSLocalizedString("Confirm", bundle: .paymentSheet, comment: "checkout button title for recurring payment"))
    }

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
