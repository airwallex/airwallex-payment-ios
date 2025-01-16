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
         returnActionHandler: ((BaseTextField) -> Void)? = nil) {
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
    
    var returnKeyType: UIReturnKeyType?
    
    var returnActionHandler: ((BaseTextField) -> Void)?
    
    func handleTextDidUpdate(textField: BaseTextField, to userInput: String) {
        let cvcLength = maxLengthGetter()
        text = String(userInput.filterIllegalCharacters(in: .decimalDigits.inverted).prefix(cvcLength))
        if text?.count == cvcLength {
            returnActionHandler?(textField)
        }
    }
    
    func handleDidEndEditing() {
        do {
            try AWXCardValidator.validate(cvc: text, requiredLength: maxLengthGetter())
            errorHint = nil
        } catch {
            guard let error = error as? String else { return }
            errorHint = error
        }
    }
}
