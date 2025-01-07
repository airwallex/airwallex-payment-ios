//
//  InfoCollectorTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//


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
            guard let error = error as? String else { return }
            errorHint = error
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
        default:
            guard let text, !text.isEmpty else {
                throw defaultErrorMessage
            }
        }
    }
}
