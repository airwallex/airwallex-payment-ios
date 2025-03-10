//
//  CardNumberFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class CardNumberFormatter: UserInputFormatter {
    
    private(set) var currentBrand: AWXBrandType = .unknown
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> (NSAttributedString?, Bool) {
        var userInput = textField.text?
            .replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        let maxLength = AWXCardValidator.shared().maxLength(forCardNumber: userInput)
        userInput = String(userInput.prefix(maxLength))
        
        var cardBrandType: AWXBrandType = .unknown
        if !userInput.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: userInput) {
            cardBrandType = brand.type
        }
        currentBrand = cardBrandType
        
        let attributedText = formatText(
            userInput,
            brand: cardBrandType,
            defaultTextAttributes: textField.defaultTextAttributes
        )
        
        // Check if the user has provided a valid input and if the cursor is at the end of the text field.
        let shouldTriggerReturn = shouldTriggerReturn(
            modifiedInput: userInput,
            range: range,
            replacementString: string,
            maxLength: maxLength
        )
        return (attributedText, shouldTriggerReturn)
    }
    
    func formatText(_ text: String,
                    brand: AWXBrandType,
                    defaultTextAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString? {
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
