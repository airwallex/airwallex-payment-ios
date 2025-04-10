//
//  InfoCollectorTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

protocol UserInputValidator {
    func validateUserInput(_ text: String?) throws
}

protocol UserInputFormatter {
    var maxLength: Int { get }
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString
}

extension UserInputFormatter {
    func shouldAutomaticTriggerReturnAction(textField: UITextField) -> Bool {
        guard let selectedRange = textField.selectedTextRange else {
            return false
        }
        let text = textField.text ?? ""
        return selectedRange.end == textField.endOfDocument && text.count >= maxLength
    }
}

protocol UserEditingEventObserver: UITextFieldDelegate {}

class InfoCollectorTextFieldViewModel: NSObject, InfoCollectorTextFieldConfiguring {
    typealias ReconfigureHandler = (InfoCollectorTextFieldViewModel, Bool) -> Void
    typealias ReturnActionHandler = (UIResponder) -> Bool
    
    var inputValidator: UserInputValidator
    
    var inputFormatter: UserInputFormatter?
    
    var reconfigureHandler: ReconfigureHandler
    
    var returnActionHandler: ReturnActionHandler?
    
    var editingEventObserver: UserEditingEventObserver?
    
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
    
    var clearButtonMode: UITextField.ViewMode
    
    var returnKeyType: UIReturnKeyType
    
    var textFieldDelegate: (any UITextFieldDelegate)? {
        return self
    }
    
    // MARK: -
    init(fieldName: String = "",
         textFieldType: AWXTextFieldType = .default,
         title: String? = nil,
         text: String? = nil,
         attributedText: NSAttributedString? = nil,
         placeholder: String? = nil,
         errorHint: String? = nil,
         isRequired: Bool = true,
         isEnabled: Bool = true,
         isValid: Bool = true,
         hideErrorHintLabel: Bool = false,
         clearButtonMode: UITextField.ViewMode = .never,
         returnKeyType: UIReturnKeyType = .default,
         returnActionHandler: ReturnActionHandler? = nil,
         customInputFormatter: UserInputFormatter? = nil,
         customInputValidator: UserInputValidator? = nil,
         editingEventObserver: UserEditingEventObserver? = nil,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.fieldName = fieldName
        self.isRequired = isRequired
        self.isEnabled = isEnabled
        self.hideErrorHintLabel = hideErrorHintLabel
        self.title = title
        self.errorHint = errorHint
        self.text = text
        if let attributedText {
            self.attributedText = attributedText
            self.text = attributedText.string
        } else if let text {
            self.text = text
        }
        self.isValid = isValid
        self.textFieldType = textFieldType
        self.placeholder = placeholder
        self.clearButtonMode = clearButtonMode
        self.returnKeyType = returnKeyType
        self.returnActionHandler = returnActionHandler
        if let customInputValidator {
            self.inputValidator = customInputValidator
        } else {
            self.inputValidator = InfoCollectorDefaultValidator(
                fieldType: textFieldType,
                isRequired: isRequired,
                title: title
            )
        }
        self.inputFormatter = customInputFormatter
        self.editingEventObserver = editingEventObserver
        self.reconfigureHandler = reconfigureHandler
    }
}

// MARK: - UITextFieldDelegate
extension InfoCollectorTextFieldViewModel: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingEventObserver?.textFieldDidBeginEditing?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        
        if let inputFormatter {
            let formated = inputFormatter.formatUserInput(
                textField,
                changeCharactersIn: range,
                replacementString: string
            )
            
            textField.updateContentAndCursor(attributedText: formated)
            attributedText = textField.attributedText
            text = attributedText?.string
            
            // trigger return action if we have a valid input, and the cursor is at the end of the text field
            if let returnActionHandler, inputFormatter.shouldAutomaticTriggerReturnAction(textField: textField) {
                _ = returnActionHandler(textField)
            }
            return false
        } else {
            let userInput = textField.text?.replacingCharacters(in: range, with: string)
            text = userInput
            attributedText = nil
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnActionHandler  {
            let success = returnActionHandler(textField)
            if !success {
                textField.resignFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        handleDidEndEditing(reconfigureIfNeeded: true)
    }
}

extension InfoCollectorTextFieldViewModel {
    convenience init(returnActionHandler: ReturnActionHandler? = nil,
                     cvcValidator: CardCVCValidator,
                     editingEventObserver: UserEditingEventObserver,
                     reconfigureHandler: @escaping ReconfigureHandler) {
        self.init(
            textFieldType: .CVC,
            placeholder: "CVC",
            returnActionHandler: returnActionHandler,
            customInputFormatter: cvcValidator,
            customInputValidator: cvcValidator,
            editingEventObserver: editingEventObserver,
            reconfigureHandler: reconfigureHandler
        )
    }
    
    func validate() throws {
        try inputValidator.validateUserInput(attributedText?.string ?? text)
    }
    
    func handleDidEndEditing(reconfigureIfNeeded: Bool) {
        let isValidCheck = isValid
        let errorHintCheck = errorHint
        do {
            try validate()
            isValid = true
            errorHint = nil
        } catch {
            isValid = false
            errorHint = error.localizedDescription
        }
        
        let needReconfigure = (isValidCheck != isValid || errorHintCheck != errorHint)
        if needReconfigure && reconfigureIfNeeded {
            reconfigureHandler(self, true)
        }
    }
}
