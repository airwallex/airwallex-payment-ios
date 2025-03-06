//
//  CardCVCTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardCVCTextFieldViewModel: BaseTextFieldConfiguring {
    var maxLengthGetter: () -> Int

    init(maxLengthGetter: @escaping () -> Int,
         returnKeyType: UIReturnKeyType = .default,
         returnActionHandler: ((UITextField) -> Void)? = nil) {
        self.maxLengthGetter = maxLengthGetter
        self.returnKeyType = returnKeyType
        self.returnActionHandler = returnActionHandler
    }
    var isEnabled: Bool = true
    
    var errorHint: String? = nil
    
    var text: String? = nil
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var textFieldType: AWXTextFieldType? = .CVC
    
    var placeholder: String? = "CVC"
    
    var returnKeyType: UIReturnKeyType
    
    var returnActionHandler: ((UITextField) -> Void)?
    
    func handleTextShouldChange(textField: UITextField, range: Range<String.Index>, replacementString string: String) -> Bool {
        let cvcLength = maxLengthGetter()
        var userInput = textField.text?.replacingCharacters(in: range, with: string).filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        text = String(userInput.prefix(cvcLength))
        if text?.count == cvcLength {
            returnActionHandler?(textField)
        }
        return false
    }
    
    func handleDidEndEditing() {
        do {
            try AWXCardValidator.validate(cvc: text, requiredLength: maxLengthGetter())
            errorHint = nil
        } catch {
            errorHint = error.localizedDescription
        }
    }
}
