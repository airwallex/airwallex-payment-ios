//
//  PaymentUIContext.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif

/// Internal context for a single payment flow.
///
/// This class replaces direct access to `AWXUIContext.shared.delegate` and
/// `AWXUIContext.shared.dismissAction` in section controllers, allowing
/// each payment flow to have its own isolated context.
@MainActor
class PaymentUIContext {

    /// The delegate that receives payment result callbacks.
    weak var delegate: AWXPaymentResultDelegate?

    /// The action to dismiss the payment UI after payment completion.
    /// This is `nil` for embedded payment elements since they don't auto-dismiss.
    var dismissAction: PaymentSessionHandler.DismissActionBlock?

    /// Creates a new payment UI context.
    /// - Parameters:
    ///   - delegate: The delegate that receives payment result callbacks.
    ///   - dismissAction: The action to dismiss the payment UI. Pass `nil` for embedded elements.
    init(delegate: AWXPaymentResultDelegate?,
         dismissAction: PaymentSessionHandler.DismissActionBlock?) {
        self.delegate = delegate
        self.dismissAction = dismissAction
    }
}
