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
    public let name: String?

    /**
     display name of the payment method.
     */
    public let displayName: String?

    /**
     transaction_mode of the payment method. One of oneoff, recurring.
     */
    public let transactionMode: String?

    /**
     flows of the payment method.
     */
    public let flows: [String]?

    /**
     transaction_currencies of the payment method.  "*", "AUD", "CHF", "HKD", "SGD", "JPY", "EUR", "GBP", "USD", "CAD", "NZD", "CNY"
     */
    public let transactionCurrencies: [String]?

    /**
     Whether payment method is active.
     */
    public let active: Bool

    /**
     Resources
     */
    public let resources: AWXResources?

    /**
     Whether it has schema
     */
    public var hasSchema: Bool {
        resources?.hasSchema == true
    }

    /**
     Supported card schemes
     */
    public let cardSchemes: [AWXCardScheme]?

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

    public init(name: String?, displayName: String?, transactionMode: String?, flows: [String]?, transactionCurrencies: [String]?, active: Bool, resources: AWXResources?, cardSchemes: [AWXCardScheme]?) {
        self.name = name
        self.displayName = displayName
        self.transactionMode = transactionMode
        self.flows = flows
        self.transactionCurrencies = transactionCurrencies
        self.active = active
        self.resources = resources
        self.cardSchemes = cardSchemes
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentMethodType {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXPaymentMethodType.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentMethodType(name: nil, displayName: nil, transactionMode: nil, flows: nil, transactionCurrencies: nil, active: false, resources: nil, cardSchemes: nil)
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
