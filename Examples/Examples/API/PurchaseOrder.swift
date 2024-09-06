//
//  PurchaseOrder.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/5.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class PurchaseOrder: Encodable {
    let products: [PhysicalProduct]
    let shipping: Shipping?
    let type: String?
    
    init(products: [PhysicalProduct], shipping: Shipping?, type: String?) {
        self.products = products
        self.shipping = shipping
        self.type = type
    }
}

class PhysicalProduct: Encodable {
    let type: String?
    let code: String?
    let name: String?
    let sku: String?
    let quantity: Int?
    let unitPrice: Decimal?
    let desc: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case code
        case name
        case sku
        case quantity
        case unitPrice = "unit_price"
        case desc
        case url
    }
    
    init(type: String?, code: String?, name: String?, sku: String?, quantity: Int?, unitPrice: Decimal?, desc: String?, url: String?) {
        self.type = type
        self.code = code
        self.name = name
        self.sku = sku
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.desc = desc
        self.url = url
    }
}

class Shipping: Encodable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let address: Address?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case address
    }
    
    init(firstName: String?, lastName: String?, phoneNumber: String?, address: Address?) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.address = address
    }
}

class Address: Encodable {
    let countryCode: String?
    let state: String?
    let city: String?
    let street: String?
    let postcode: String?
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case state
        case city
        case street
        case postcode
    }
    
    init(countryCode: String?, state: String?, city: String?, street: String?, postcode: String?) {
        self.countryCode = countryCode
        self.state = state
        self.city = city
        self.street = street
        self.postcode = postcode
    }
}
