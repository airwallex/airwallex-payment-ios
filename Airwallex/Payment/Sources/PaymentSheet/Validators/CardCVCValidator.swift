//
//  CardCVCValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#endif

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
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        let cvcLength = maxLength
        let before = textField.text ?? ""
        let string = string.filterIllegalCharacters(in: .decimalDigits.inverted)
        var after = before.replacingCharacters(in: range, with: string)
        let attributedText = NSAttributedString(string: after, attributes: textField.defaultTextAttributes)
        let range = NSRange(location: 0, length: min(cvcLength, attributedText.length))
        return attributedText.attributedSubstring(from: range)
    }
}

extension CardCVCValidator {
    init(cardName: String) {
        let brand = AWXCardValidator.shared().brand(forCardName: cardName)
        let cvcLength = AWXCardValidator.cvcLength(for: brand?.type ?? .unknown)
        self.init(maxLength: cvcLength)
    }
}
