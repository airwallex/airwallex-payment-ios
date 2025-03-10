//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardNumberTextFieldViewModel: InfoCollectorTextFieldViewModel, CardNumberTextFieldConfiguring {
    let supportedBrands = AWXBrandType.supportedBrands
    
    var currentBrand: AWXBrandType = .unknown
    
    let supportedCardSchemes: [AWXCardScheme]
    
    init(supportedCardSchemes: [AWXCardScheme],
         reconfigureHandler: @escaping ReconfigureHandler) {
        self.supportedCardSchemes = supportedCardSchemes
        super.init(
            textFieldType: .cardNumber,
            placeholder: "1234 1234 1234 1234",
            customInputValidator: CardNumberValidator(supportedCardSchemes: supportedCardSchemes),
            reconfigureHandler: reconfigureHandler
        )
    }
}

extension CardNumberTextFieldViewModel {
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        defer {
            //  update text
            reconfigureHandler(self, false)
        }
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


