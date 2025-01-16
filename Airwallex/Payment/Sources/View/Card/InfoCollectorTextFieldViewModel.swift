//
//  InfoCollectorTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//


class InfoCollectorTextFieldViewModel: InfoCollectorCellConfiguring {
    var customTextModifier: ((String?) -> (String?, NSAttributedString?, Bool))?
    
    var customInputValidator: ((String?) throws -> Void)?
    
    init(fieldName: String,
         isRequired: Bool = true,
         isEnabled: Bool = true,
         hideErrorHintLabel: Bool = false,
         isValid: Bool = true,
         title: String? = nil,
         errorHint: String? = nil,
         text: String? = nil,
         attributedText: NSAttributedString? = nil,
         textFieldType: AWXTextFieldType? = .default,
         placeholder: String? = nil,
         returnKeyType: UIReturnKeyType? = nil,
         returnActionHandler: ((BaseTextField) -> Void)? = nil,
         customTextModifier: ((String?) -> (String?, NSAttributedString?, Bool))? = nil,
         customInputValidator: ((String?) throws -> Void)? = nil,
         triggerLayoutUpdate: (() -> Void)? = nil) {
        self.fieldName = fieldName
        self.isRequired = isRequired
        self.isEnabled = isEnabled
        self.hideErrorHintLabel = hideErrorHintLabel
        self.title = title
        self.errorHint = errorHint
        self.text = text
        self.attributedText = attributedText
        self.isValid = isValid
        self.textFieldType = textFieldType
        self.placeholder = placeholder
        self.returnKeyType = returnKeyType
        self.returnActionHandler = returnActionHandler
        self.customTextModifier = customTextModifier
        self.customInputValidator = customInputValidator
        self.triggerLayoutUpdate = triggerLayoutUpdate
    }
    // MARK: InfoCollectorTextFieldConfiguring
    var fieldName: String
    
    var isRequired: Bool = true
    
    var hideErrorHintLabel = false
    
    var isEnabled = true
    
    var title: String?
    
    var errorHint: String?
    
    var text: String?
    
    var attributedText: NSAttributedString?
    
    var isValid: Bool
    
    var textFieldType: AWXTextFieldType?
    
    var placeholder: String?
    
    var triggerLayoutUpdate: (() -> Void)?
    
    var returnKeyType: UIReturnKeyType?
    
    var returnActionHandler: ((BaseTextField) -> Void)?
    
    func handleTextDidUpdate(textField: BaseTextField, to userInput: String) {
        if let customTextModifier {
            let (text, attributedText, triggerNextField) = customTextModifier(userInput)
            self.text = text
            self.attributedText = attributedText
            
            if triggerNextField, let returnActionHandler {
                returnActionHandler(textField)
            }
            return
        }
        guard !userInput.isEmpty else {
            text = nil
            attributedText = nil
            return
        }
        text = userInput
    }
    
    func handleDidEndEditing() {
        do {
            if textFieldType == .phoneNumber {
                text = text?.filterIllegalCharacters(in: .whitespacesAndNewlines)
            }
            if let customInputValidator {
                try customInputValidator(text)
            } else {
                try validateUserInput(text)
            }
            isValid = true
            errorHint = nil
        } catch {
            isValid = false
            guard let error = error as? String else { return }
            errorHint = error
        }
    }
}

extension InfoCollectorTextFieldViewModel {
    func validateUserInput(_ text: String?) throws {
        // prefer custom validator
        if let customInputValidator {
            try customInputValidator(text)
            return
        }
        if !isRequired && (text == nil || text?.isEmpty == true) {
            return
        }
        let defaultErrorMessage = NSLocalizedString("Invalid \(title ?? "input")", bundle: .payment, comment: "")
        guard let textFieldType else {
            throw defaultErrorMessage
        }	
        switch textFieldType {
        case .firstName:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Please enter your first name", bundle: .payment, comment: "")
            }
        case .lastName:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Please enter your last name", bundle: .payment, comment: "")
            }
        case .country:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Please enter your country", bundle: .payment, comment: "")
            }
        case .state:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Invalid state", bundle: .payment, comment: "")
            }
        case .city:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Please enter your city", bundle: .payment, comment: "")
            }
        case .street:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Please enter your street", bundle: .payment, comment: "")
            }
        case .nameOnCard:
            guard let text, !text.isEmpty else {
                throw NSLocalizedString("Please enter your card name", bundle: .payment, comment: "")
            }
        case .email:
            guard let text, text.isValidEmail else {
                throw NSLocalizedString("Invalid email", bundle: .payment, comment: "")
            }       
        default:
            guard let text, !text.isEmpty else {
                throw defaultErrorMessage
            }
        }
    }
}
