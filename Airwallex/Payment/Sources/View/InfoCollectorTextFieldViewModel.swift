//
//  InfoCollectorTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

protocol UserInputValidator {
    func validateUserInput(_ text: String?) throws
}

class InfoCollectorTextFieldViewModel: NSObject, InfoCollectorCellConfiguring {
    typealias ReconfigureHandler = (InfoCollectorTextFieldViewModel, Bool) -> Void
                                    
    var customTextModifier: ((String?) -> (String?, NSAttributedString?, Bool))?
    
    var inputValidator: UserInputValidator
    
    var reconfigureHandler: ((InfoCollectorTextFieldViewModel, Bool) -> Void)
    
    init(fieldName: String = "",
         isRequired: Bool = true,
         isEnabled: Bool = true,
         hideErrorHintLabel: Bool = false,
         isValid: Bool = true,
         title: String? = nil,
         errorHint: String? = nil,
         text: String? = nil,
         attributedText: NSAttributedString? = nil,
         textFieldType: AWXTextFieldType = .default,
         placeholder: String? = nil,
         returnKeyType: UIReturnKeyType = .default,
         returnActionHandler: ((UITextField) -> Void)? = nil,
         customTextModifier: ((String?) -> (String?, NSAttributedString?, Bool))? = nil,
         customInputValidator: UserInputValidator? = nil,
         reconfigureHandler: @escaping ReconfigureHandler) {
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
        if let customInputValidator {
            self.inputValidator = customInputValidator
        } else {
            self.inputValidator = InfoCollectorDefaultValidator(
                fieldType: textFieldType,
                isRequired: isRequired,
                title: title
            )
        }
        self.reconfigureHandler = reconfigureHandler
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
    
    var returnKeyType: UIReturnKeyType
    
    var returnActionHandler: ((UITextField) -> Void)?
    
    func handleDidEndEditing() {
        do {
            try inputValidator.validateUserInput(text)
            isValid = true
            errorHint = nil
        } catch {
            isValid = false
            errorHint = error.localizedDescription
            DispatchQueue.main.async {
                // deplay to next runloop to avoid deadlock in NSDiffableDataSource
                // e.g. a reload action cause the editing textField to resign first responder, then there
                // will be a reload and a reconfigure happened at the same time which might cause deadlock
                self.reconfigureHandler(self, true)
                // TODO: maybe we can optimize this, and not always pass true for layout update
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension InfoCollectorTextFieldViewModel {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        let userInput = textField.text?.replacingCharacters(in: range, with: string)
        if let customTextModifier {
            let (text, attributedText, triggerNextField) = customTextModifier(userInput)
            self.text = text
            self.attributedText = attributedText
            if triggerNextField, let returnActionHandler {
                returnActionHandler(textField)
            }
            
            //  update text
            reconfigureHandler(self, false)
            
            return false
        }
        guard userInput?.isEmpty == false else {
            text = nil
            attributedText = nil
            return true
        }
        text = userInput
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnActionHandler  {
            returnActionHandler(textField)
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        handleDidEndEditing()
    }
}
