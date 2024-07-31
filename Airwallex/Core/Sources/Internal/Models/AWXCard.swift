//
//  AWXCard.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXCard` includes the information of a card.
@objcMembers
@objc
public class AWXCard: NSObject, Codable {
    /**
     Card number.
     */
    public var number: String?

    /**
     Two digit number representing the card’s expiration month. Example: 12.
     */
    public var expiryMonth: String?

    /**
     Four digit number representing the card’s expiration year. Example: 2030.
     */
    public var expiryYear: String?

    /**
     Card holder name.
     */
    public var name: String?

    /**
     Card cvc.
     */
    public var cvc: String?

    /**
     Bank identify number of this card.
     */
    public var bin: String?

    /**
     Last four digits of the card number.
     */
    public var last4: String?

    /**
     Brand of the card.
     */
    public var brand: String?

    /**
     Country code of the card.
     */
    public var country: String?

    /**
     Funding type of the card.
     */
    public var funding: String?

    /**
     Fingerprint of the card.
     */
    public var fingerprint: String?

    /**
     Whether CVC pass the check.
     */
    public var cvcCheck: String?

    /**
     Whether address pass the check.
     */
    public var avsCheck: String?

    /**
     Type of the number. One of PAN, EXTERNAL_NETWORK_TOKEN, AIRWALLEX_NETWORK_TOKEN.
     */
    public var numberType: String?

    enum CodingKeys: String, CodingKey {
        case number
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case name
        case cvc
        case bin
        case last4
        case brand
        case country
        case funding
        case fingerprint
        case cvcCheck = "cvc_check"
        case avsCheck = "avs_check"
        case numberType = "number_type"
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decodeIfPresent(String.self, forKey: .number)
        expiryMonth = try container.decodeIfPresent(String.self, forKey: .expiryMonth)
        expiryYear = try container.decodeIfPresent(String.self, forKey: .expiryYear)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        cvc = try container.decodeIfPresent(String.self, forKey: .cvc)
        bin = try container.decodeIfPresent(String.self, forKey: .bin)
        last4 = try container.decodeIfPresent(String.self, forKey: .last4)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        funding = try container.decodeIfPresent(String.self, forKey: .funding)
        fingerprint = try container.decodeIfPresent(String.self, forKey: .fingerprint)
        cvcCheck = try container.decodeIfPresent(String.self, forKey: .cvcCheck)
        avsCheck = try container.decodeIfPresent(String.self, forKey: .avsCheck)
        numberType = try container.decodeIfPresent(String.self, forKey: .numberType)

        if number == nil, let last4 = last4 {
            number = "••••\(last4)"
        }
    }

    override public init() {
        super.init()
    }
}

@objc public extension AWXCard {
    func validate() -> String? {
        if number == nil || !AWXCardValidator.shared().isValidCardLength(number ?? "") {
            return "Invalid card number"
        }
        if name == nil || name?.count == 0 {
            return "Invalid name on card"
        }
        if expiryYear == nil || expiryMonth == nil || expiryYear?.count == 0 || expiryMonth?.count == 0 {
            return "Invalid expires date"
        }
        if cvc == nil || cvc?.count == 0 {
            return "Invalid CVC / CVV"
        }
        return nil
    }

    static func decodeFromJSON(_ dic: [String: Any]) -> AWXCard {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXCard.self, from: jsonData)

            return result
        } catch {
            return AWXCard()
        }
    }
}
