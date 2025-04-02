//
//  CardNumberFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(Core)
import Core
#endif

class CardNumberFormatter: UserInputFormatter {
    
    private(set) var currentBrand: AWXBrandType = .unknown
    
    private(set) var maxLength: Int = AWXCardValidator.shared().maxLength(forCardNumber: "")
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        let userInput = textField.text?
            .replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        
        var cardBrandType: AWXBrandType = .unknown
        if !userInput.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: userInput) {
            cardBrandType = brand.type
        }
        currentBrand = cardBrandType
        
        maxLength = AWXCardValidator.shared().maxLength(forCardNumber: userInput)
        let attributedText = formatText(
            userInput,
            brand: cardBrandType,
            attributes: textField.defaultTextAttributes
        )
        guard maxLength >= attributedText.length else {
            let range = NSRange(location: 0, length: min(maxLength, attributedText.length))
            return attributedText.attributedSubstring(from: range)
        }
        return attributedText
    }
    
    private func formatText(_ text: String,
                            brand: AWXBrandType,
                            attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: attributes
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
