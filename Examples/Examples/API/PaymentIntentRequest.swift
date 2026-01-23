//
//  PaymentIntentRequest.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/5.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class PaymentIntentRequest: Encodable {
    let requestID = UUID().uuidString
    let amount: Decimal
    let currency: String
    let merchantOrderID = UUID().uuidString
    let order: PurchaseOrder
    let metadata: [String: Int]
    let returnUrl: String?
    let customerID: String?
    let paymentMethodOptions: [String: [String: String]]?
    let apiKey: String?
    let clientID: String?
    private let referrerData: [String: String]? = ["type": "ios_sdk_sample"]
    
    enum CodingKeys: String, CodingKey {
        case requestID = "request_id"
        case amount
        case currency
        case merchantOrderID = "merchant_order_id"
        case order
        case metadata
        case returnUrl = "return_url"
        case customerID = "customer_id"
        case paymentMethodOptions = "payment_method_options"
        case apiKey
        case clientID = "clientId"
        case referrerData = "referrer_data"
    }
    
    init(amount: Decimal, currency: String, order: PurchaseOrder, metadata: [String: Int], returnUrl: String?, customerID: String?, paymentMethodOptions: [String: [String: String]]?, apiKey: String?, clientID: String?) {
        self.amount = amount
        self.currency = currency
        self.order = order
        self.metadata = metadata
        self.returnUrl = returnUrl
        self.customerID = customerID
        self.paymentMethodOptions = paymentMethodOptions
        self.apiKey = apiKey
        self.clientID = clientID
    }
}
