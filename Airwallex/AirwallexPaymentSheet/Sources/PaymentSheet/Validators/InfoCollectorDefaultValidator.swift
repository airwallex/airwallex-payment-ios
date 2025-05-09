//
//  InfoCollectorDefaultValidator.swift
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

struct InfoCollectorDefaultValidator: UserInputValidator {
    
    let fieldType: AWXTextFieldType
    let isRequired: Bool
    let title: String?
    
    init(fieldType: AWXTextFieldType, isRequired: Bool, title: String? = nil) {
        self.fieldType = fieldType
        self.isRequired = isRequired
        self.title = title
    }
    
    func validateUserInput(_ text: String?) throws {
        
        if !isRequired && (text == nil || text?.trimmed.isEmpty == true) {
            return
        }
        let defaultErrorMessage = NSLocalizedString("Invalid \(title ?? "input")", bundle: .paymentSheet, comment: "user input validation")
        
        switch fieldType {
        case .firstName:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your first name", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .lastName:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your last name", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .country:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your country", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .state:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Invalid state", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .city:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your city", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .street:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your street", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .nameOnCard:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your name on card", bundle: .paymentSheet, comment: "user input validation"))
            }
        case .email:
            guard let text = text?.trimmed, text.isValidEmail else {
                throw NSLocalizedString("Invalid email", bundle: .paymentSheet, comment: "user input validation").asError()
            }
        case .phoneNumber:
            guard let text, text.isValidE164PhoneNumber else {
                throw NSLocalizedString("Invalid phone number", bundle: .paymentSheet, comment: "user input validation").asError()
            }
        default:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: defaultErrorMessage)
            }
        }
    }
}
