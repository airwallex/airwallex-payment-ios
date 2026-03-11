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

/// Internal context for a single payment flow used by low-level API integration.
@MainActor
class PaymentUIContext: PaymentUIContextProviding {

    weak var viewController: UIViewController?
    weak var delegate: AWXPaymentResultDelegate?
    var hasPaymentUI: Bool { false }

    init(viewController: UIViewController? = nil,
         delegate: AWXPaymentResultDelegate? = nil) {
        self.viewController = viewController
        self.delegate = delegate
    }

    func completePaymentSession() async {}
}
