//
//  CardCVCTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

// TODO: replace with InfoCollectorTextFieldViewModel directly
class CardCVCTextFieldViewModel: InfoCollectorTextFieldViewModel {
    
    private let cvcValidator: CardCVCValidator
    
    init(cvcValidator: CardCVCValidator,
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.cvcValidator = cvcValidator
        super.init(
            textFieldType: .CVC,
            placeholder: "CVC",
            customInputValidator: cvcValidator,
            reconfigureHandler: reconfigureHandler
        )
    }
    // TODO: text formatter for cvc
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        defer {
            //  update text
            reconfigureHandler(self, false)
        }
        let cvcLength = cvcValidator.maxLength
        var userInput = textField.text?.replacingCharacters(in: range, with: string).filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        text = String(userInput.prefix(cvcLength))
        if text?.count == cvcLength {
            returnActionHandler?(textField)
        }
        return false
    }
}
