//
//  CardExpiryValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#endif

struct CardExpiryValidator: UserInputValidator {
    func validateUserInput(_ text: String?) throws {
        guard let text, !text.isEmpty else {
            throw NSLocalizedString("Expiry date is required", bundle: .payment, comment: "").asError()
        }
        let components = text.components(separatedBy: "/")
        try AWXCardValidator.validate(expiryMonth: components.first, expiryYear: components.last)
    }
}
