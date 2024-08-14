//
//  AWXGetPaymentMethodTypesConfiguration.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/8/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objcMembers
@objc
public class AWXGetPaymentMethodTypesConfiguration: NSObject, Codable {
    public var active: Bool = false
    public var pageNum: Int = 0
    public var pageSize: Int = 20
    public var transactionCurrency: String?
    public var transactionMode: String?
    public var countryCode: String?
    public var resources: Bool = true
    public var lang: String?
    public var flow: String? = "inapp"

    public var path: String {
        "api/v1/pa/config/payment_method_types"
    }

    enum CodingKeys: String, CodingKey {
        case active
        case pageNum = "page_num"
        case pageSize = "page_size"
        case transactionCurrency = "transaction_currency"
        case transactionMode = "transaction_mode"
        case countryCode = "country_code"
        case resources = "__resources"
        case lang
        case flow
    }

    public var parameters: [String: String]? {
        guard let dictionary = toDictionary() else {
            return nil
        }
        var stringDictionary: [String: String] = [:]

        for (key, value) in dictionary {
            if let intValue = value as? Int {
                stringDictionary[key] = String(intValue)
            } else if let boolValue = value as? Bool {
                stringDictionary[key] = boolValue ? "true" : "false"
            } else if let doubleValue = value as? Double {
                stringDictionary[key] = String(doubleValue)
            } else if let stringValue = value as? String {
                stringDictionary[key] = stringValue
            } else {
                print("Warning: \(key) is not a supported type and will be skipped.")
            }
        }

        return stringDictionary
    }
}
