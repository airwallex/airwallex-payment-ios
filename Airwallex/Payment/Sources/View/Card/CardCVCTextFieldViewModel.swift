//
//  CardCVCTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardCVCTextFieldViewModel: ErrorHintableTextFieldConfiguring {
    
    var maxLengthGetter: () -> Int
    
    var errorHint: String? = nil
    
    var text: String? = nil
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var textFieldType: AWXTextFieldType? = .CVC
    
    var placeholder: String? = "CVC"
    
    init(maxLengthGetter: @escaping () -> Int) {
        self.maxLengthGetter = maxLengthGetter
    }
    
    func handleTextDidUpdate(to userInput: String) -> Bool {
        text = String(userInput.filterIllegalCharacters(in: .decimalDigits.inverted).prefix(maxLengthGetter()))
        return text?.count == maxLengthGetter()
    }
    
    func handleDidEndEditing() {
        guard let text else {
            errorHint = NSLocalizedString("Security code is required", bundle: .payment, comment: "")
            return
        }
        guard text.count == maxLengthGetter() else {
            errorHint = NSLocalizedString("Security code is invalid", bundle: .payment, comment: "")
            return
        }
        errorHint = nil
    }
}
