//
//  AWXPaymentMethod.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXPaymentMethod` includes the information of a payment method.
@objcMembers
@objc
public class AWXPaymentMethod: NSObject, Codable {
    /**
     Type of the payment method. One of card, wechatpay, applepay.
     */
    public let type: String?

    /**
     Unique identifier for the payment method.
     */
    public let id: String?

    /**
     Billing object.
     */
    public let billing: AWXPlaceDetails?

    /**
     Card object.
     */
    public let card: AWXCard?

    /**
     Additional params  for wechat, redirect or applepay type.
     */
    public var additionalParams: [String: String]?

    /**
     The customer this payment method belongs to.
     */
    public let customerId: String?

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case billing
        case card
        case additionalParams
        case customerId = "customer_id"
    }

    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }

        init?(intValue _: Int) {
            return nil
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dynamicContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        if let type, let key = DynamicCodingKeys(stringValue: type) {
            try dynamicContainer.encode(additionalParams, forKey: key)
        }
        try container.encode(type, forKey: .type)
        try container.encode(billing, forKey: .billing)
        try container.encode(card, forKey: .card)
        try container.encode(customerId, forKey: .customerId)
    }

    public init(type: String?, id: String?, billing: AWXPlaceDetails?, card: AWXCard?, additionalParams: [String: String]?, customerId: String?) {
        self.type = type
        self.id = id
        self.billing = billing
        self.card = card
        self.additionalParams = additionalParams
        self.customerId = customerId
    }
}

@objc public extension AWXPaymentMethod {
    func appendAdditionalParams(_ params: [String: String]) {
        if additionalParams == nil {
            additionalParams = params
        } else {
            additionalParams?.merge(params) { _, new in new }
        }
    }

    static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentMethod {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXPaymentMethod.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentMethod(type: nil, id: nil, billing: nil, card: nil, additionalParams: nil, customerId: nil)
        }
    }

    func encodeToJSON() -> [String: Any] {
        return toDictionary() ?? [String: Any]()
    }
}
