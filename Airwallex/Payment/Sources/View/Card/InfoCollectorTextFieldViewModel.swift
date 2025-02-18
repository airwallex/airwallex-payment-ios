//
//  InfoCollectorTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if SWIFT_PACKAGE
import AirwallexCore
#endif

class InfoCollectorTextFieldViewModel: InfoCollectorTextFieldConfiguring {
    var title: String?
    
    var errorHint: String?
    
    var text: String?
    
    var attributedText: NSAttributedString?
    
    var isValid: Bool
    
    var textFieldType: AWXTextFieldType?
    
    var placeholder: String?
    
    func handleTextDidUpdate(to userInput: String) -> Bool {
        guard !userInput.isEmpty else {
            text = nil
            return false
        }
        text = userInput
        return false
    }
    
    func handleDidEndEditing() {
        do {
            try validateUserInput(text)
            errorHint = nil
        } catch {
            errorHint = error.localizedDescription
        }
    }
    
    init(title: String? = nil,
         errorHint: String? = nil,
         text: String? = nil,
         attributedText: NSAttributedString? = nil,
         isValid: Bool = true,
         textFieldType: AWXTextFieldType? = .default,
         placeholder: String? = nil) {
        self.title = title
        self.errorHint = errorHint
        self.text = text
        self.attributedText = attributedText
        self.isValid = isValid
        self.textFieldType = textFieldType
        self.placeholder = placeholder
    }
}

extension InfoCollectorTextFieldViewModel {
    func validateUserInput(_ text: String?) throws {
        var defaultErrorMessage = NSLocalizedString("Invalid \(title ?? "input")", bundle: .payment, comment: "")
        guard let textFieldType else {
            throw ErrorMessage(rawValue: defaultErrorMessage)
        }
        switch textFieldType {
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
        default:
            guard let text, !text.isEmpty else {
                throw ErrorMessage(rawValue: defaultErrorMessage)
            }
        }
    }
}
