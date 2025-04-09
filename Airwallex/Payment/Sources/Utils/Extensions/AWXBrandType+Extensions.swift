//
//  AWXBrandType.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#elseif canImport(AirwallexCore)
import AirwallexCore
#endif

extension AWXBrandType {
    public static var supportedBrands: [AWXBrandType] {
        [.visa, .mastercard, .amex, .unionPay, .JCB, dinersClub, .discover]
    }
}
