//
//  CreateCustomerResponse.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

struct CreateCustomerResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case requestID = "request_id"
        case merchantCustomerID = "merchant_customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case additionalInfo = "additional_info"
        case metadata
        case clientSecret = "client_secret"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    let id: String
    let requestID: String
    let merchantCustomerID: String
    let firstName: String
    let lastName: String
    let email: String?
    let phoneNumber: String?
    let additionalInfo: CreateCustomerRequestAdditionalInfo
    let metadata: [String: String]
    let clientSecret: String
    let createdAt: String
    let updatedAt: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.requestID = try container.decode(String.self, forKey: .requestID)
        self.merchantCustomerID = try container.decode(String.self, forKey: .merchantCustomerID)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.additionalInfo = try container.decode(CreateCustomerRequestAdditionalInfo.self, forKey: .additionalInfo)
        self.metadata = try container.decode([String: String].self, forKey: .metadata)
        self.clientSecret = try container.decode(String.self, forKey: .clientSecret)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}
