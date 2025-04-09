//
//  AWXCardBrand+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#elseif canImport(AirwallexCore)
import AirwallexCore
#endif

public extension AWXCardBrand {
    static var all: [AWXCardBrand] {
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
}
