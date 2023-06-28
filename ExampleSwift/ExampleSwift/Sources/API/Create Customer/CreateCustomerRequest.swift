//
//  CreateCustomerRequest.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

struct CreateCustomerRequest: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case requestID = "request_id"
        case merchantCustomerID = "merchant_customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case additionalInfo = "additional_info"
        case metadata
    }
    
    let requestID: String
    let merchantCustomerID: String
    let firstName: String
    let lastName: String
    let email: String?
    let phoneNumber: String?
    let additionalInfo: CreateCustomerRequestAdditionalInfo
    let metadata: [String: String]
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.requestID, forKey: .requestID)
        try container.encode(self.merchantCustomerID, forKey: .merchantCustomerID)
        try container.encode(self.firstName, forKey: .firstName)
        try container.encode(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try container.encode(self.additionalInfo, forKey: .additionalInfo)
        try container.encode(self.metadata, forKey: .metadata)
    }
}

struct CreateCustomerRequestAdditionalInfo: Codable {
    
    enum CodingKeys: String, CodingKey {
        case isRegisteredViaSocialMedia = "registered_via_social_media"
        case registrationDate = "registration_date"
        case firstSuccessfulOrderDate = "first_successful_order_date"
    }
    
    let isRegisteredViaSocialMedia: Bool
    let registrationDate: String?
    let firstSuccessfulOrderDate: String?
    
    init(
        isRegisteredViaSocialMedia: Bool,
        registrationDate: String?,
        firstSuccessfulOrderDate: String?
    ) {
        self.isRegisteredViaSocialMedia = isRegisteredViaSocialMedia
        self.registrationDate = registrationDate
        self.firstSuccessfulOrderDate = firstSuccessfulOrderDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isRegisteredViaSocialMedia = try container.decode(Bool.self, forKey: .isRegisteredViaSocialMedia)
        self.registrationDate = try container.decodeIfPresent(String.self, forKey: .registrationDate)
        self.firstSuccessfulOrderDate = try container.decodeIfPresent(String.self, forKey: .firstSuccessfulOrderDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isRegisteredViaSocialMedia, forKey: .isRegisteredViaSocialMedia)
        try container.encodeIfPresent(self.registrationDate, forKey: .registrationDate)
        try container.encodeIfPresent(self.firstSuccessfulOrderDate, forKey: .firstSuccessfulOrderDate)
    }
}
