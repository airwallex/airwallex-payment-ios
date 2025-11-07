//
//  PaymentIntentProvider.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 6/11/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

@objc
public protocol PaymentIntentProvider {
    func createPaymentIntent(customerID: String?,
                             currency: String,
                             amount: NSDecimalNumber) async throws -> AWXPaymentIntent

    var currency: String { get }
    var amount: NSDecimalNumber { get }
    var customerId: String? { get }
}
