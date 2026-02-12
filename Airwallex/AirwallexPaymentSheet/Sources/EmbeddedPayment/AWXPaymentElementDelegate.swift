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

    /// Called when payment processing begins.
    ///
    /// Use this to show a custom loading indicator if `showsPaymentProcessingIndicator` is `false`.
    /// - Parameters:
    ///   - element: The payment element that started payment.
    ///   - paymentMethod: The name of the payment method being used (e.g., "card", "applepay").
    @objc optional func paymentElement(_ element: AWXPaymentElement,
                                       didStartPaymentFor paymentMethod: String)

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
}
