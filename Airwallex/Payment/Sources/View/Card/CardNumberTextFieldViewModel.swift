//
//  CardNumberTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardNumberTextFieldViewModel: CardNumberTextFieldConfiguring {
    var placeholder: String? = "1234 1234 1234 1234"
    
    let textFieldType: AWXTextFieldType? = .cardNumber
    
    var text: String? {
        attributedText?.string
    }
    
    var attributedText: NSAttributedString?

    let supportedBrands = AWXBrandType.supportedBrands
    
    var currentBrand: AWXBrandType = .unknown
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var errorHint: String? = nil
    
    func handleTextDidUpdate(to userInput: String) {
        // check max length
        let userInput = userInput.filterIllegalCharacters(in: .decimalDigits.inverted)
        guard userInput.count <= AWXCardValidator.shared().maxLength(forCardNumber: userInput) else { return}
        
        var cardBrandType: AWXBrandType = .unknown
        if !userInput.isEmpty, let brand = AWXCardValidator.shared().brand(forCardNumber: userInput) {
            cardBrandType = brand.type
        }
        
        attributedText = formatText(userInput, brand: cardBrandType)
        currentBrand = cardBrandType
    }
    
    func handleDidEndEditing() {
        let cardNumber = attributedText?.string ?? ""
        guard !cardNumber.isEmpty else {
            errorHint = NSLocalizedString("Card number is required", bundle: .payment, comment: "")
            return
        }
        guard AWXCardValidator.shared().isValidCardLength(cardNumber) else {
            errorHint = NSLocalizedString("Card number is invalid", bundle: .payment, comment: "")
            return
        }
        let cardName = AWXCardValidator.shared().brand(forCardNumber: cardNumber)?.name ?? ""
        guard supportedCardSchemes.contains(where: { $0.name.lowercased() == cardName.lowercased() }) else {
            errorHint = NSLocalizedString("Card not supported for payment", bundle: .payment, comment: "")
            return
        }
        errorHint = nil
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


