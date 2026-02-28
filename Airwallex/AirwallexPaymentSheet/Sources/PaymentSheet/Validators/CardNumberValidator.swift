//
//  CardNumberValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

struct CardNumberValidator: UserInputValidator {
    
    let supportedCardSchemes: [AWXCardScheme]
    
    func validateUserInput(_ text: String?) throws {
        try AWXCardValidator.validate(number: text, supportedSchemes: supportedCardSchemes)
    }
}
