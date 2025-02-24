//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardNumberTextFieldViewModel: CardNumberTextFieldConfiguring {
    var isEnabled: Bool = true
    
    var placeholder: String? = "1234 1234 1234 1234"
    
    let textFieldType: AWXTextFieldType? = .cardNumber
    
    var text: String? {
        attributedText?.string
    }
    
    var attributedText: NSAttributedString?

    let supportedBrands = AWXBrandType.supportedBrands
    
    var currentBrand: AWXBrandType = .unknown
    
    var isValid: Bool {
        errorHint == nil
    }
    
    var errorHint: String? = nil
    
    var returnKeyType: UIReturnKeyType = .default
    
    var returnActionHandler: ((UITextField) -> Void)? = nil
    
    func handleTextShouldChange(textField: UITextField, range: Range<String.Index>, replacementString string: String) -> Bool {
        var userInput = textField.text?
            .replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        let maxLength = AWXCardValidator.shared().maxLength(forCardNumber: userInput)
        userInput = String(userInput.prefix(maxLength))
        
        var cardBrandType: AWXBrandType = .unknown
        if !userInput.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: userInput) {
            cardBrandType = brand.type
        }
        
        attributedText = formatText(userInput, brand: cardBrandType)
        currentBrand = cardBrandType
        if userInput.count == maxLength {
            guard let cursorIndex = userInput.index(
                range.lowerBound,
                offsetBy: string.count,
                limitedBy: userInput.endIndex
            ) else {
                returnActionHandler?(textField)
                return false
            }
            if cursorIndex == userInput.endIndex {
                returnActionHandler?(textField)
            }
        }
        return false
    }
    
    func handleDidEndEditing() {
        let cardNumber = attributedText?.string ?? ""
        do {
            try AWXCardValidator.validate(number: cardNumber, supportedSchemes: supportedCardSchemes)
            errorHint = nil
        } catch {
            guard let error = error as? String else { return }
            errorHint = error
        }
    }
    
    let supportedCardSchemes: [AWXCardScheme]
    
    init(supportedCardSchemes: [AWXCardScheme]) {
        self.supportedCardSchemes = supportedCardSchemes
    }
}

extension CardNumberTextFieldViewModel {
    
    func formatText(_ text: String, brand: AWXBrandType) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [.font: UIFont.awxFont(.body2), .foregroundColor: UIColor.awxColor(.textPrimary)]
        )
        var type: AWXBrandType = .unknown
        if !text.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: text) {
            type = brand.type
        }
        let cardNumberFormat = AWXCardValidator.cardNumberFormat(for: type)
        var index = 0
        outerLoop: for number in cardNumberFormat {
            let segmentLength = number.intValue
            var segmentIndex = 0
            for _ in 0..<segmentLength {
                guard index < text.count else { break outerLoop }
                if index + 1 != attributedString.length && segmentIndex + 1 == segmentLength {
                    attributedString.addAttribute(.kern, value: 5, range: NSRange(location: index, length: 1))
                } else {
                    attributedString.addAttribute(.kern, value: 0, range: NSRange(location: index, length: 1))
                    
                }
                index += 1
                segmentIndex += 1
            }
        }
        return attributedString
    }
}


