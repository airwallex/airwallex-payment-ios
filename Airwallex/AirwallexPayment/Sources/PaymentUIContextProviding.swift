//
//  PaymentUIContextProviding.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 2026/3/5.
//  Copyright © 2026 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import UIKit

@MainActor
package protocol PaymentUIContextProviding: AnyObject {
    var viewController: UIViewController? { get }
    var delegate: AWXPaymentResultDelegate? { get }
/// Whether the payment is running within a UI context (payment sheet or embedded element).
    /// Used to decide whether to keep the payment UI alive on intermediate statuses like `.inProgress`.
    var hasPaymentUI: Bool { get }
}
