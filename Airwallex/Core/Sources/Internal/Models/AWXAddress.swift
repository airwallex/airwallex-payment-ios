//
//  AWXAddress.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXAddress` includes the information of an address.
@objcMembers
@objc
public class AWXAddress: NSObject, Codable {
    /**
     Country code of the address. Use the two-character ISO Standard Country Codes.
     */
    public var countryCode: String?

    /**
     City of the address.
     */
    public var city: String?

    /**
     Street of the address.
     */
    public var street: String?

    /**
     State or province of the address, optional.
     */
    public var state: String?

    /**
     Postcode of the address, optional.
     */
    public var postcode: String?

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case city
        case street
        case state
        case postcode
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXAddress {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXAddress.self, from: jsonData)

            return result
        } catch {
            return AWXAddress()
        }
    }
}
