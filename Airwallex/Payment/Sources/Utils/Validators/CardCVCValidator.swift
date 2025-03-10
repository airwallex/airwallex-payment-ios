//
//  CardCVCValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct CardCVCValidator: UserInputValidator, UserInputFormatter {
    
    var maxLength: Int {
        lengthGetter?() ?? fixedLength ?? AWXCardValidator.cvcLength(for: .unknown)
    }
    
    private let fixedLength: Int?
    private let lengthGetter: (() -> Int)?
    
    init(maxLength: Int) {
        self.fixedLength = maxLength
        self.lengthGetter = nil
    }
    
    init(maxLengthGetter: @escaping (() -> Int)) {
        self.fixedLength = nil
        self.lengthGetter = maxLengthGetter
    }
    
    func validateUserInput(_ text: String?) throws {
        let cvcLength = lengthGetter?() ?? fixedLength ?? AWXCardValidator.cvcLength(for: .unknown)
        try AWXCardValidator.validate(cvc: text, requiredLength: cvcLength)
    }
    
    func formatUserInput(_ textField: UITextField, changeCharactersIn range: Range<String.Index>, replacementString string: String) -> (NSAttributedString?, Bool) {
        let cvcLength = maxLength
        var userInput = textField.text?.replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        let text = String(userInput.prefix(cvcLength))
        
        let shouldTriggerReturn = shouldTriggerReturn(
            modifiedInput: userInput,
            range: range,
            replacementString: string,
            maxLength: maxLength
        )
        return (NSAttributedString(string: text, attributes: textField.defaultTextAttributes), shouldTriggerReturn)
    }
}

extension CardCVCValidator {
    init(cardName: String) {
        let brand = AWXCardValidator.shared().brand(forCardName: cardName)
        let cvcLength = AWXCardValidator.cvcLength(for: brand?.type ?? .unknown)
        self.init(maxLength: cvcLength)
    }
}
