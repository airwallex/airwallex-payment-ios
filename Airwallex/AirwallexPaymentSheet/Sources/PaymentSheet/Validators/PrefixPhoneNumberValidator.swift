//
//  PrefixPhoneNumberValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/13.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

struct PrefixPhoneNumberValidator: UserInputValidator {
    
    let prefix: String?
    
    func validateUserInput(_ text: String?) throws {
        guard let text, text.isValidE164PhoneNumber else {
            throw NSLocalizedString("Invalid phone number", bundle: .paymentSheet, comment: "user input validation").asError()
        }
        
        if let prefix, text.hasPrefix(prefix) == true {
            guard text.count > prefix.count else {
                throw NSLocalizedString("Invalid phone number", bundle: .paymentSheet, comment: "user input validation").asError()
            }
        }
    }
}
