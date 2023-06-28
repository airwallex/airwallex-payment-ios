//
//  CreatePaymentIntentRequest.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 17/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

struct CreatePaymentIntentRequest: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case merchantOrderID = "merchant_order_id"
        case requestID = "request_id"
        case metadata
        case returnURL = "return_url"
        case order
        case customerID = "customer_id"
    }
    
    let amount: String
    let currency: String
    let merchantOrderID: String
    let requestID: String
    let metadata: [String: String]
    let returnURL: String
    let order: CreatePaymentIntentRequestOrder
    let customerID: String?
    
    init(
        amount: String,
        currency: String,
        merchantOrderID: String,
        requestID: String,
        metadata: [String: String],
        returnURL: String,
        order: CreatePaymentIntentRequestOrder,
        customerID: String?
    ) {
        self.amount = amount
        self.currency = currency
        self.merchantOrderID = merchantOrderID
        self.requestID = requestID
        self.metadata = metadata
        self.returnURL = returnURL
        self.order = order
        self.customerID = customerID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.merchantOrderID, forKey: .merchantOrderID)
        try container.encode(self.requestID, forKey: .requestID)
        try container.encode(self.metadata, forKey: .metadata)
        try container.encode(self.returnURL, forKey: .returnURL)
        try container.encode(self.order, forKey: .order)
        try container.encode(self.customerID, forKey: .customerID)
    }
}

struct CreatePaymentIntentRequestOrder: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case products
        case shipping
        case type
    }
    
    let products: [Product]
    let shipping: Shipping
    let type: String
    
    init(
        products: [Product],
        shipping: Shipping,
        type: String
    ) {
        self.products = products
        self.shipping = shipping
        self.type = type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.products, forKey: .products)
        try container.encode(self.shipping, forKey: .shipping)
        try container.encode(self.type, forKey: .type)
    }
}
