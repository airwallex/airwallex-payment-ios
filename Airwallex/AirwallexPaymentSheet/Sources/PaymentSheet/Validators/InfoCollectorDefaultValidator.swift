//
//  InfoCollectorDefaultValidator.swift
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

struct InfoCollectorDefaultValidator: UserInputValidator {
    
    let fieldType: AWXTextFieldType
    let isRequired: Bool
    let title: String?
    let language: AWXPaymentLanguage
    
    init(fieldType: AWXTextFieldType,
         isRequired: Bool,
         title: String? = nil,
         language: AWXPaymentLanguage = .english) {
        self.fieldType = fieldType
        self.isRequired = isRequired
        self.title = title
        self.language = language
    }
    
    func validateUserInput(_ text: String?) throws {
        
        if !isRequired && (text == nil || text?.trimmed.isEmpty == true) {
            return
        }
        let defaultErrorMessage = if let title {
            String(format: NSLocalizedString("Invalid %@", bundle: .paymentSheet.language(language), comment: "user input validation"), title.lowercased())
        } else {
            NSLocalizedString("Invalid user input", bundle: .paymentSheet.language(language), comment: "user input validation")
        }
        
        switch fieldType {
        case .firstName:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your first name", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .lastName:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your last name", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .country:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your country", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .state:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Invalid state", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .city:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your city", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .street:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your street", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .nameOnCard:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your name on card", bundle: .paymentSheet.language(language), comment: "user input validation"))
            }
        case .email:
            guard let text = text?.trimmed, text.isValidEmail else {
                throw NSLocalizedString("Invalid email", bundle: .paymentSheet.language(language), comment: "user input validation").asError()
            }
        case .phoneNumber:
            guard let text, text.isValidE164PhoneNumber else {
                throw NSLocalizedString("Invalid phone number", bundle: .paymentSheet.language(language), comment: "user input validation").asError()
            }
        default:
            guard let text = text?.trimmed, !text.isEmpty else {
                throw ErrorMessage(rawValue: defaultErrorMessage)
            }
        }
    }
}
