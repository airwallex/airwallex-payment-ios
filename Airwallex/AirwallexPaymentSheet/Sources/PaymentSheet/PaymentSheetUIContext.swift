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
@_spi(AWX) import AirwallexPayment
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
    var isEmbedded: Bool = false

    /// Whether Apple Pay is prioritized (shown at top).
    var prioritizeApplePay: Bool = true

    /// Shared image loader for payment method icons.
    private(set) lazy var imageLoader = ImageLoader()
}
