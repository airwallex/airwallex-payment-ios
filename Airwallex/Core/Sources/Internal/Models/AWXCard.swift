//
//  AWXCard.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXCard` includes the information of a card.
 */
@objcMembers
@objc(AWXCardSwift)
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
    
    enum CodingKeys:String, CodingKey {
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
    
    required public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number = try container.decodeIfPresent(String.self, forKey: .number)
        self.expiryMonth = try container.decodeIfPresent(String.self, forKey: .expiryMonth)
        self.expiryYear = try container.decodeIfPresent(String.self, forKey: .expiryYear)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.cvc = try container.decodeIfPresent(String.self, forKey: .cvc)
        self.bin = try container.decodeIfPresent(String.self, forKey: .bin)
        self.last4 = try container.decodeIfPresent(String.self, forKey: .last4)
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.funding = try container.decodeIfPresent(String.self, forKey: .funding)
        self.fingerprint = try container.decodeIfPresent(String.self, forKey: .fingerprint)
        self.cvcCheck = try container.decodeIfPresent(String.self, forKey: .cvcCheck)
        self.avsCheck = try container.decodeIfPresent(String.self, forKey: .avsCheck)
        self.numberType = try container.decodeIfPresent(String.self, forKey: .numberType)
        
        if number == nil, let last4 = last4 {
            number = "••••\(last4)"
        }
    }

}

@objc extension AWXCard {
    public func validate() -> String? {
        if let number = number, !AWXCardValidator.shared().isValidCardLength(number) {
            return "Invalid card number"
        }
        if name?.count == 0 {
            return "Invalid name on card"
        }
        if expiryYear?.count == 0 || expiryMonth?.count == 0 {
            return "Invalid expires date"
        }
        if cvc?.count == 0 {
            return "Invalid CVC / CVV"
        }
        return nil
    }
}
