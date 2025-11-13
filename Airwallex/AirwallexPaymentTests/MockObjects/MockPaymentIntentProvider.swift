//
//  MockPaymentIntentProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 11/11/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment

// MARK: - Mock Payment Intent Provider

class MockPaymentIntentProvider: NSObject, PaymentIntentProvider {
    let customerId: String?
    let currency: String
    let amount: NSDecimalNumber

    init(customerId: String?, currency: String, amount: NSDecimalNumber) {
        self.customerId = customerId
        self.currency = currency
        self.amount = amount
    }

    func createPaymentIntent() async throws -> AWXPaymentIntent {
        let intent = AWXPaymentIntent()
        intent.customerId = customerId
        intent.currency = currency
        intent.amount = amount
        intent.id = "test_intent_from_provider_\(UUID().uuidString)"
        intent.clientSecret = "test_client_secret_\(UUID().uuidString)"
        return intent
    }
}

class MockPaymentIntentProviderWithError: NSObject, PaymentIntentProvider {
    var customerId: String? { "error_customer" }
    var currency: String { "USD" }
    var amount: NSDecimalNumber { NSDecimalNumber(value: 100) }

    func createPaymentIntent() async throws -> AWXPaymentIntent {
        throw NSError(
            domain: "TestErrorDomain",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Mock provider error"]
        )
    }
}
