//
//  CustomerRequest.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/6.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CustomerRequest: Encodable {
    let requestID = UUID().uuidString
    let merchantCustomerID = UUID().uuidString
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNumber: String?
    let additionalInfo: Dictionary<String, Any>?
    let metadata: Dictionary<String, Int>
    
    enum CodingKeys: String, CodingKey {
        case requestID
        case merchantCustomerID = "merchant_customer_id"
        case firstName
        case lastName
        case email
        case phoneNumber
        case additionalInfo
        case metadata
    }
    
    init(firstName: String?, lastName: String?, email: String?, phoneNumber: String?, additionalInfo: Dictionary<String, Encodable>?, metadata: Dictionary<String, Int>) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.additionalInfo = additionalInfo
        self.metadata = metadata
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestID, forKey: .requestID)
        try container.encode(merchantCustomerID, forKey: .merchantCustomerID)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        if let additionalInfo, let jsonData = try? JSONSerialization.data(withJSONObject: additionalInfo) {
            try container.encode(jsonData, forKey: .additionalInfo)
        }
        try container.encode(metadata, forKey: .metadata)
    }
}
