//
//  Shipping.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 17/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

struct Shipping: Encodable {
    
    struct Address: Encodable {
        enum CodingKeys: String, CodingKey {
            case street
            case city
            case state
            case postcode
            case countryCode = "country_code"
        }
        
        let street: String
        let city: String
        let state: String
        let postcode: String
        let countryCode: String
        
        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<Shipping.Address.CodingKeys> = encoder.container(keyedBy: Shipping.Address.CodingKeys.self)
            try container.encode(self.street, forKey: Shipping.Address.CodingKeys.street)
            try container.encode(self.city, forKey: Shipping.Address.CodingKeys.city)
            try container.encode(self.state, forKey: Shipping.Address.CodingKeys.state)
            try container.encode(self.postcode, forKey: Shipping.Address.CodingKeys.postcode)
            try container.encode(self.countryCode, forKey: Shipping.Address.CodingKeys.countryCode)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case dateOfBirth = "date_of_birth"
        case phoneNumber = "phone_number"
        case address
    }
    
    let firstName: String
    let lastName: String
    let email: String?
    let dateOfBirth: String?
    let phoneNumber: String
    let address: Address
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encode(self.email, forKey: .dateOfBirth)
        try container.encode(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encode(self.phoneNumber, forKey: .phoneNumber)
        try container.encode(self.address, forKey: .address)
    }
}

extension Shipping {
    var description: String {
        return """
\(firstName) \(lastName)
\(address.street) \(address.city)
\(address.state) \(address.countryCode)
"""
    }
    
    // Convert back to the Airwallex SDK type.
    // Replace this once we upgrade the SDK to Swift and we can use the same
    // Codable object.
    func asAWXPlaceDetails() -> AWXPlaceDetails {
        return AWXPlaceDetails(
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            address: AWXAddress(
                street: address.street,
                city: address.city,
                state: address.state,
                postcode: address.postcode,
                countryCode: address.countryCode
            )
        )
    }
}
