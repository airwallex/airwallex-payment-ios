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

protocol UserInputFormatter {
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> (NSAttributedString?, Bool)
}

extension UserInputFormatter {
    func shouldTriggerReturn(modifiedInput input: String?,
                             range: Range<String.Index>,
                             replacementString string: String,
                             maxLength: Int) -> Bool {
        guard let input else { return false }
        // check max length
        let check1 = input.count == maxLength
        
        // check cursor index
        let endCursor = input.index(
            range.lowerBound,
            offsetBy: string.count,
            limitedBy: input.endIndex
        ) ?? input.endIndex
        let check2 = endCursor == input.endIndex
        
        return check1 && check2
    }
}

class InfoCollectorTextFieldViewModel: NSObject, InfoCollectorCellConfiguring {
    typealias ReconfigureHandler = (InfoCollectorTextFieldViewModel, Bool) -> Void
    
    var inputValidator: UserInputValidator
    
    var inputFormatter: UserInputFormatter?
    
    var reconfigureHandler: ((InfoCollectorTextFieldViewModel, Bool) -> Void)
    
    var returnActionHandler: ((UITextField) -> Void)?
    
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
    
    var textFieldDelegate: (any UITextFieldDelegate)? {
        return self
    }
    
    // MARK: -
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
         customInputFormatter: UserInputFormatter? = nil,
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
        self.reconfigureHandler = reconfigureHandler
    }
}

// MARK: - UITextFieldDelegate
extension InfoCollectorTextFieldViewModel: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        
        if let inputFormatter {
            let (attributedText, triggerReturnAction) = inputFormatter.formatUserInput(
                textField,
                changeCharactersIn: range,
                replacementString: string
            )
            text = attributedText?.string
            self.attributedText = attributedText
            //  update text
            reconfigureHandler(self, false)
            // trigger return action if we have a valid input, and the cursor is at the end of the text field
            if triggerReturnAction, let returnActionHandler {
                returnActionHandler(textField)
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
            returnActionHandler(textField)
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        handleDidEndEditing(reconfigureIfNeeded: true)
    }
}

extension InfoCollectorTextFieldViewModel {
    convenience init(cvcValidator: CardCVCValidator,
                     reconfigureHandler: @escaping ReconfigureHandler) {
        self.init(
            textFieldType: .CVC,
            placeholder: "CVC",
            customInputFormatter: cvcValidator,
            customInputValidator: cvcValidator,
            reconfigureHandler: reconfigureHandler
        )
    }
    
    func validate() throws {
        try inputValidator.validateUserInput(attributedText?.string ?? text)
    }
    
    func handleDidEndEditing(reconfigureIfNeeded: Bool = false) {
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
