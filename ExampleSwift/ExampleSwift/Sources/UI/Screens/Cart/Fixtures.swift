//
//  Fixtures.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 27/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

class Fixtures {
    static func makeShipping() -> Shipping {
        return Shipping(
            firstName: "John",
            lastName: "Smith",
            email: nil,
            dateOfBirth: nil,
            phoneNumber: "61400000000",
            address: Shipping.Address(
                street: "7/15 William St",
                city: "Melbourne",
                state: "Victoria",
                postcode: "3000",
                countryCode: "AU"
            )
        )
    }
    
    static func makeProducts() -> [Product] {
        return [
            Product(
                code: "123",
                description: "Rebuilt from the sound up.",
                name: "AirPods Pro",
                quantity: 1,
                sku: "piece",
                type: "Free engraving",
                unitPrice: 399.0,
                url: "www.apple.com"
            ),
            Product(
                code: "456",
                description: "Immersive, high-fidelity audio.",
                name: "HomePod",
                quantity: 1,
                sku: "piece",
                type: "White",
                unitPrice: 469.0,
                url: "www.apple.com"
            )
        ]
    }
}
