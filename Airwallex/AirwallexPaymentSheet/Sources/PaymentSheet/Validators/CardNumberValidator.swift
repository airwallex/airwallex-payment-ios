//
//  CardNumberValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

struct CardNumberValidator: UserInputValidator {
    
    let supportedCardSchemes: [AWXCardScheme]
    
    init(supportedCardSchemes: [AWXCardScheme]) {
        self.supportedCardSchemes = supportedCardSchemes
    }
    
    func validateUserInput(_ text: String?) throws {
        try AWXCardValidator.validate(number: text, supportedSchemes: supportedCardSchemes)
    }
}
