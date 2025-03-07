//
//  InfoCollectorDefaultValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

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
        
        if !isRequired && (text == nil || text?.isEmpty == true) {
            return
        }
        var defaultErrorMessage = NSLocalizedString("Invalid \(title ?? "input")", bundle: .payment, comment: "")
        
        switch fieldType {
        case .firstName:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your first name", bundle: .payment, comment: ""))
            }
        case .lastName:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your last name", bundle: .payment, comment: ""))
            }
        case .country:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your country", bundle: .payment, comment: ""))
            }
        case .state:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Invalid state", bundle: .payment, comment: ""))
            }
        case .city:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your city", bundle: .payment, comment: ""))
            }
        case .street:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your street", bundle: .payment, comment: ""))
            }
        case .nameOnCard:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: NSLocalizedString("Please enter your card name", bundle: .payment, comment: ""))
            }
        case .email:
            guard let text, text.isValidEmail else {
                throw NSLocalizedString("Invalid email", bundle: .payment, comment: "").asError()
            }
        case .phoneNumber:
            guard let text, text.isValidE164PhoneNumber else {
                throw NSLocalizedString("Invalid phone number", bundle: .payment, comment: "").asError()
            }
        default:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: defaultErrorMessage)
            }
        }
    }
}
