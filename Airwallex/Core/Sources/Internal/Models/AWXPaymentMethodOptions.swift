//
//  AWXPaymentMethodOptions.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXPaymentMethodOptions` includes the info of payment consent.
@objcMembers
@objc
public class AWXPaymentMethodOptions: NSObject, Codable {
    /**
     The options for card.
     */
    public let cardOptions: AWXCardOptions?

    enum CodingKeys: String, CodingKey {
        case cardOptions = "card"
    }

    public init(cardOptions: AWXCardOptions?) {
        self.cardOptions = cardOptions
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentMethodOptions {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXPaymentMethodOptions.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentMethodOptions(cardOptions: nil)
        }
    }

    public func encodeToJSON() -> [String: Any] {
        return toDictionary() ?? [String: Any]()
    }
}
