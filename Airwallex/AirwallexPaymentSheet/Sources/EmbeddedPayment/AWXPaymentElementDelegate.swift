//
//  AWXPaymentElementDelegate.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
#endif

/// A delegate protocol for receiving payment result callbacks from an embedded payment element.
///
/// Implement this protocol to handle payment completion events when using `AWXPaymentElement`.
@MainActor
@objc public protocol AWXPaymentElementDelegate: AnyObject {

    /// Called when payment completes, fails, or is canceled.
    ///
    /// - Parameters:
    ///   - element: The payment element that completed the payment flow.
    ///   - status: The status of the payment (success, failure, or cancel).
    ///   - error: An error object if the payment failed, otherwise `nil`.
    func paymentElement(_ element: AWXPaymentElement,
                        didCompleteWith status: AirwallexPaymentStatus,
                        error: Error?)

    /// Called when a payment consent is created for recurring payments.
    ///
    /// This method is optional and is only called when a payment consent is successfully created,
    /// typically for recurring payment sessions.
    ///
    /// - Parameters:
    ///   - element: The payment element that created the consent.
    ///   - consentId: The ID of the created payment consent.
    @objc optional func paymentElement(_ element: AWXPaymentElement,
                                       didCompleteWithPaymentConsentId consentId: String)
}
