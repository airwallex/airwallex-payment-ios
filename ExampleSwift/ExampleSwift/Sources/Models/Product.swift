//
//  Product.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

struct Product: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case description = "desc"
        case name
        case quantity
        case sku
        case type
        case unitPrice = "unit_price"
        case url
        
    }
    
    let code: String
    let description: String
    let name: String
    let quantity: Int
    let sku: String
    let type: String
    let unitPrice: Decimal
    let url: String
    
    init(
        code: String,
        description: String,
        name: String,
        quantity: Int,
        sku: String,
        type: String,
        unitPrice: Decimal,
        url: String
    ) {
        self.code = code
        self.description = description
        self.name = name
        self.quantity = quantity
        self.sku = sku
        self.type = type
        self.unitPrice = unitPrice
        self.url = url
    }
 
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.quantity, forKey: .quantity)
        try container.encode(self.sku, forKey: .sku)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.unitPrice, forKey: .unitPrice)
        try container.encode(self.url, forKey: .url)
    }
}
