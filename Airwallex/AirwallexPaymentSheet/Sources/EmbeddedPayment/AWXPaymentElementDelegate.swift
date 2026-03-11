//
//  AWXPaymentElementDelegate.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

/// Delegate protocol for receiving payment events from AWXPaymentElement.
///
/// This delegate replaces `AWXPaymentResultDelegate` for AWXPaymentElement,
/// providing payment lifecycle notifications with method information.
@MainActor
@objc public protocol AWXPaymentElementDelegate: AnyObject {

    /// Called when payment processing state changes.
    ///
    /// Implement this method to display a custom loading indicator during payment processing.
    /// This method is called with `isProcessing: true` when payment starts, and
    /// `isProcessing: false` when payment completes (before `didCompleteFor` is called).
    /// If this method is not implemented, a default loading indicator will be shown.
    ///
    /// - Parameters:
    ///   - element: The payment element.
    ///   - paymentMethod: The name of the payment method being used (e.g., "card", "applepay").
    ///   - isProcessing: `true` when payment starts, `false` when payment ends.
    @objc optional func paymentElement(_ element: AWXPaymentElement,
                                       onProcessingStateChangedFor paymentMethod: String,
                                       isProcessing: Bool)

    /// Called when payment processing completes.
    ///
    /// - Parameters:
    ///   - element: The payment element that completed payment.
    ///   - paymentMethod: The name of the payment method used.
    ///   - status: The result status of the payment.
    ///   - error: The error if payment failed, nil otherwise.
    func paymentElement(_ element: AWXPaymentElement,
                        didCompleteFor paymentMethod: String,
                        with status: AirwallexPaymentStatus,
                        error: Error?)

    /// Called when a payment consent is created.
    ///
    /// - Parameters:
    ///   - element: The payment element.
    ///   - paymentMethod: The name of the payment method used.
    ///   - paymentConsentId: The ID of the created payment consent.
    @objc optional func paymentElement(_ element: AWXPaymentElement,
                                       didCompleteFor paymentMethod: String,
                                       withPaymentConsentId paymentConsentId: String)

    /// Called when input validation fails, allowing the host app to scroll the first
    /// invalid field into the visible area.
    ///
    /// Since the payment element is embedded inside the host app's view hierarchy,
    /// the SDK cannot determine how to scroll content into view. Implement this method
    /// to ensure the provided view is visible to the user (e.g., by calling
    /// `scrollRectToVisible(_:animated:)` on the enclosing scroll view, converting
    /// the view's frame with `convert(_:from:)` as needed).
    ///
    /// - Parameters:
    ///   - element: The payment element.
    ///   - paymentMethod: The name of the payment method being validated (e.g., "card").
    ///   - invalidInputView: The view containing the first invalid input field that should be scrolled into view.
    @objc optional func paymentElement(_ element: AWXPaymentElement,
                                       validationFailedFor paymentMethod: String,
                                       invalidInputView: UIView)
}
