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
        let before = textField.text ?? ""
        let string = string.filterIllegalCharacters(in: .decimalDigits.inverted)
        let after = before.replacingCharacters(in: range, with: string)
        
        var cardBrandType: AWXBrandType = .unknown
        if !after.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: after) {
            cardBrandType = brand.type
        }
        currentBrand = cardBrandType
        
        maxLength = AWXCardValidator.shared().maxLength(forCardNumber: after)
        let attributedText = formatText(
            after,
            brand: cardBrandType,
            attributes: textField.defaultTextAttributes
        )
        let range = NSRange(location: 0, length: min(maxLength, attributedText.length))
        return attributedText.attributedSubstring(from: range)
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
