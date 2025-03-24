//
//  AWXCardScheme+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

#if canImport(Card)
import Card
#endif

extension AWXCardScheme {
    static var allAvailable: [AWXCardScheme] {
        AWXCardBrand.all.map {
            let scheme = AWXCardScheme()
            scheme.name = $0.rawValue
            return scheme
        }
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
