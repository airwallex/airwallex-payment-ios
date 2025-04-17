//
//  AWXCardBrand+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif

public extension AWXCardBrand {
    static var allAvailable: [AWXCardBrand] {
        [
            AWXCardBrand.visa,
            AWXCardBrand.mastercard,
            AWXCardBrand.amex,
            AWXCardBrand.JCB,
            AWXCardBrand.dinersClub,
            AWXCardBrand.discover,
            AWXCardBrand.unionPay
        ]
    }
    
    var brandType: AWXBrandType {
        switch self {
        case AWXCardBrand.visa:
            return .visa
        case AWXCardBrand.mastercard:
            return .mastercard
        case AWXCardBrand.amex:
            return .amex
        case AWXCardBrand.JCB:
            return .JCB
        case AWXCardBrand.dinersClub:
            return .dinersClub
        case AWXCardBrand.discover:
            return .discover
        case AWXCardBrand.unionPay:
            return .unionPay
        default:
            return .unknown
        }
    }
}
