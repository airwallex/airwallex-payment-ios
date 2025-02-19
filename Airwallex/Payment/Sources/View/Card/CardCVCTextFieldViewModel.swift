//
//  CardCVCTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardCVCTextFieldViewModel: BaseTextFieldConfiguring {
    var isEnabled: Bool = true
    
    var errorHint: String? = nil
    
    var text: String? = nil
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var textFieldType: AWXTextFieldType? = .CVC
    
    var placeholder: String? = "CVC"
    
    var maxLengthGetter: () -> Int

    init(maxLengthGetter: @escaping () -> Int) {
        self.maxLengthGetter = maxLengthGetter
    }
    
    func handleTextDidUpdate(to userInput: String) -> Bool {
        text = String(userInput.filterIllegalCharacters(in: .decimalDigits.inverted).prefix(maxLengthGetter()))
        return text?.count == maxLengthGetter()
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
