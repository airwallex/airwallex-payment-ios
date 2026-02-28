//
//  PaymentUIContext.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 2025/1/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import UIKit

/// Internal context for a single payment flow.
///
/// This class replaces direct access to `AWXUIContext.shared.delegate` and
/// `AWXUIContext.shared.dismissAction` in section controllers, allowing
/// each payment flow to have its own isolated context.
///
/// Subclass this in higher-level modules to add additional configuration properties.
@MainActor
open class PaymentUIContext {

    /// A block type for dismissing the payment UI.
    /// The block takes a completion handler that should be called after dismissal is complete.
    public typealias DismissActionBlock = (@escaping () -> Void) -> Void

    /// The view controller that hosts the payment UI.
    public weak var viewController: UIViewController?

    /// The delegate that receives payment result callbacks.
    public weak var delegate: AWXPaymentResultDelegate?

    /// The action to dismiss the payment UI after payment completion.
    /// This is `nil` for embedded payment elements since they don't auto-dismiss.
    public var dismissAction: DismissActionBlock?

    /// Creates a new payment UI context.
    /// - Parameters:
    ///   - delegate: The delegate that receives payment result callbacks.
    ///   - dismissAction: The action to dismiss the payment UI. Pass `nil` for embedded elements.
    public init(viewController: UIViewController? = nil,
                delegate: AWXPaymentResultDelegate? = nil,
                dismissAction: DismissActionBlock? = nil) {
        self.viewController = viewController
        self.delegate = delegate
        self.dismissAction = dismissAction
    }

    /// Call this function to dismiss payment UI
    /// - Parameter completion: completion block called after dismissal
    public func dismiss(completion: (() -> Void)?) {
        guard let dismissAction else {
            completion?()
            return
        }
        dismissAction {
            completion?()
        }
        self.dismissAction = nil
    }
}
