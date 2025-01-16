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
    
    var returnKeyType: UIReturnKeyType? = nil
    
    var returnActionHandler: ((BaseTextField) -> Void)? = nil
    
    func handleTextDidUpdate(textField: BaseTextField, to userInput: String) {
        // check max length
        var userInput = userInput.filterIllegalCharacters(in: .decimalDigits.inverted)
        let maxLength = AWXCardValidator.shared().maxLength(forCardNumber: userInput)
        userInput = String(userInput.prefix(maxLength))
        
        var cardBrandType: AWXBrandType = .unknown
        if !userInput.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: userInput) {
            cardBrandType = brand.type
        }
        
        attributedText = formatText(userInput, brand: cardBrandType)
        currentBrand = cardBrandType
        if userInput.count == maxLength {
            returnActionHandler?(textField)
        }
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
    
    let supportedCardSchemes: [AWXCardScheme]?
    
    init(supportedCardSchemes: [AWXCardScheme]?) {
        self.supportedCardSchemes = supportedCardSchemes
    }
}

extension CardNumberTextFieldViewModel {
    
    func formatText(_ text: String, brand: AWXBrandType) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [.font: UIFont.awxBody, .foregroundColor: UIColor.awxTextPrimary]
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


