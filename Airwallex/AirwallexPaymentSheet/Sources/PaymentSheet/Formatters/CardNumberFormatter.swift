//
//  CardNumberFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Combine
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif

class CardNumberFormatter: UserInputFormatter {
    
    private(set) var currentBrand: AWXBrandType = .unknown
    private(set) var candidates: [AWXBrandType]
    
    private(set) var maxLength: Int = AWXCardValidator.shared().maxLength(forCardNumber: "")
    
    init(currentBrand: AWXBrandType = .unknown,
         candidates: [AWXBrandType] = AWXBrandType.allAvailable) {
        self.currentBrand = currentBrand
        self.candidates = candidates
    }
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        let userInput = textField.text?
            .replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        
        candidates = AWXCardValidator.possibleBrandTypes(forCardNumber: userInput)
        currentBrand = AWXCardValidator.shared().brand(forCardNumber: userInput).type
        maxLength = AWXCardValidator.shared().maxLength(forCardNumber: userInput)
        let attributedText = formatText(
            userInput,
            brand: currentBrand,
            attributes: textField.defaultTextAttributes
        )
        return attributedText
    }
    
    private func formatText(_ text: String,
                            brand: AWXBrandType,
                            attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: attributes
        )
        let cardNumberFormat = AWXCardValidator.cardNumberFormat(for: brand)
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
