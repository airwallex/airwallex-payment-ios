//
//  AWXBrandType.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

extension AWXBrandType {
    public static var supportedBrands: [AWXBrandType] {
        [.visa, .mastercard, .amex, .unionPay, .JCB, dinersClub, .discover]
    }
}
