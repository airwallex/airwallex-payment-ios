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
    let metadata: Dictionary<String, Int>
    let returnUrl: String
    let customerID: String?
    let paymentMethodOptions: Dictionary<String, Dictionary<String, String>>?
    
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
    }
    
    init(amount: Decimal, currency: String, order: PurchaseOrder, metadata: Dictionary<String, Int>, returnUrl: String, customerID: String?, paymentMethodOptions: Dictionary<String, Dictionary<String, String>>?) {
        self.amount = amount
        self.currency = currency
        self.order = order
        self.metadata = metadata
        self.returnUrl = returnUrl
        self.customerID = customerID
        self.paymentMethodOptions = paymentMethodOptions
    }
}
