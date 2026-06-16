//
//  RegexInputValidator.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

struct RegexInputValidator: UserInputValidator {

    let regex: NSRegularExpression?
    let isRequired: Bool
    let requiredMessage: String = NSLocalizedString("Required", bundle: .paymentSheet, comment: "Invalid user input")
    let invalidMessage: String = NSLocalizedString("Please enter a valid value", bundle: .paymentSheet, comment: "Invalid user input")

    func validateUserInput(_ text: String?) throws {
        let trimmed = text?.trimmed ?? ""
        if trimmed.isEmpty {
            if isRequired {
                throw ErrorMessage(rawValue: requiredMessage)
            }
            return
        }
        guard let regex else { return }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        if regex.firstMatch(in: trimmed, range: range) == nil {
            throw ErrorMessage(rawValue: invalidMessage)
        }
    }
}
