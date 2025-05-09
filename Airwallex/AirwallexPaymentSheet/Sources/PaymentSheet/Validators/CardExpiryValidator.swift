//
//  CardExpiryValidator.swift
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

struct CardExpiryValidator: UserInputValidator {
    func validateUserInput(_ text: String?) throws {
        guard let text, !text.isEmpty else {
            throw NSLocalizedString("Expiry date is required", bundle: .paymentSheet, comment: "user input validation").asError()
        }
        let components = text.components(separatedBy: "/")
        guard text.count == 5, components.count == 2 else {
            throw NSLocalizedString("Card’s expiration date is invalid", bundle: .paymentSheet, comment: "user input validation").asError()
        }
        let expiryYear = "20\(components.last?.suffix(2) ?? "00")"
        try AWXCardValidator.validate(expiryMonth: components.first, expiryYear: expiryYear)
    }
}
