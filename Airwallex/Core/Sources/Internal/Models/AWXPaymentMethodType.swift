//
//  AWXPaymentMethodType.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXPaymentMethodType` includes the information of a payment method.
@objcMembers
@objc
public class AWXPaymentMethodType: NSObject, Codable {
    /**
     name of the payment method.
     */
    public private(set) var name: String?

    /**
     display name of the payment method.
     */
    public private(set) var displayName: String?

    /**
     transaction_mode of the payment method. One of oneoff, recurring.
     */
    public private(set) var transactionMode: String?

    /**
     flows of the payment method.
     */
    public private(set) var flows: [String]?

    /**
     transaction_currencies of the payment method.  "*", "AUD", "CHF", "HKD", "SGD", "JPY", "EUR", "GBP", "USD", "CAD", "NZD", "CNY"
     */
    public private(set) var transactionCurrencies: [String]?

    /**
     Whether payment method is active.
     */
    public private(set) var active: Bool = false

    /**
     Resources
     */
    public private(set) var resources: AWXResources?

    /**
     Whether it has schema
     */
    public var hasSchema: Bool {
        resources?.hasSchema == true
    }

    /**
     Supported card schemes
     */
    public private(set) var cardSchemes: [AWXCardScheme]?

    enum CodingKeys: String, CodingKey {
        case name
        case displayName = "display_name"
        case transactionMode = "transaction_mode"
        case flows
        case transactionCurrencies = "transaction_currencies"
        case active
        case resources
        case cardSchemes = "card_schemes"
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentMethodType {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXPaymentMethodType.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentMethodType()
        }
    }
}

/// `AWXResources` includes the resources of payment method.
@objcMembers
@objc
public class AWXResources: NSObject, Codable {
    /**
     Logo url
     */
    public var logoURL: URL? {
        URL(string: logos?.png ?? "")
    }

    var logos: AWXLogos?

    /**
     has_schema
     */
    public var hasSchema: Bool = false

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXResources {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXResources.self, from: jsonData)

            return result
        } catch {
            return AWXResources()
        }
    }

    enum CodingKeys: String, CodingKey {
        case hasSchema = "has_schema"
        case logos
    }
}

@objcMembers
@objc
public class AWXLogos: NSObject, Codable {
    public var png: String?
    public var svg: String?
}

@objcMembers
@objc
public class AWXCardScheme: NSObject, Codable {
    public var name: String = ""

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXCardScheme {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let scheme = try decoder.decode(AWXCardScheme.self, from: jsonData)

            return scheme
        } catch {
            return AWXCardScheme()
        }
    }
}
