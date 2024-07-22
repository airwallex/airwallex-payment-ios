//
//  AWXAddress.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXAddress` includes the information of an address.
 */
@objcMembers
@objc(AWXAddressSwift)
public class AWXAddress: NSObject, Codable {
    
    /**
     Country code of the address. Use the two-character ISO Standard Country Codes.
     */
    var countryCode: String?
    
    /**
     City of the address.
     */
    var city: String?
    
    /**
     Street of the address.
     */
    var street: String?
    
    /**
     State or province of the address, optional.
     */
    var state: String?
    
    /**
     Postcode of the address, optional.
     */
    var postcode: String?
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case city
        case street
        case state
        case postcode
    }
}
