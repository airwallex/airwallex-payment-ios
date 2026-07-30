//
//  CardCVCValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

struct CardCVCValidator: UserInputValidator, UserInputFormatter {
    
    var maxLength: Int {
        lengthGetter?() ?? fixedLength ?? AWXCardValidator.cvcLength(for: .unknown)
    }
    
    private let fixedLength: Int?
    private let lengthGetter: (() -> Int)?
    private let language: AWXPaymentLanguage
    
    init(maxLength: Int,
         language: AWXPaymentLanguage = .english) {
        self.fixedLength = maxLength
        self.lengthGetter = nil
        self.language = language
    }
    
    init(maxLengthGetter: @escaping (() -> Int),
         language: AWXPaymentLanguage = .english) {
        self.fixedLength = nil
        self.lengthGetter = maxLengthGetter
        self.language = language
    }
    
    func validateUserInput(_ text: String?) throws {
        let cvcLength = lengthGetter?() ?? fixedLength ?? AWXCardValidator.cvcLength(for: .unknown)
        try AWXCardValidator.validate(
            cvc: text,
            requiredLength: cvcLength,
            language: language
        )
    }
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        let userInput = (textField.text ?? "")
            .replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted)
        let attributedText = NSAttributedString(string: userInput, attributes: textField.defaultTextAttributes)
        return attributedText
    }
}

extension CardCVCValidator {
    init(cardName: String,
         language: AWXPaymentLanguage = .english) {
        let brand = AWXCardValidator.shared().brand(forCardName: cardName)
        let cvcLength = AWXCardValidator.cvcLength(for: brand?.type ?? .unknown)
        self.init(maxLength: cvcLength, language: language)
    }
}
