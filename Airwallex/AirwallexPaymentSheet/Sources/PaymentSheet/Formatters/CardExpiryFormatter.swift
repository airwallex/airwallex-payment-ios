//
//  CardExpiryFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

struct CardExpiryFormatter: UserInputFormatter {
    
    let maxLength = 5
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        var userInput = textField.text ?? ""
        if string == "", userInput.distance(from: range.lowerBound, to: range.upperBound) > 0 {
            // deleting, update selectedTextRange as we will remove all characters after current cusor position
            textField.selectedTextRange = textField.textRange(
                from: textField.selectedTextRange?.start ?? textField.beginningOfDocument,
                to: textField.endOfDocument
            )
            userInput = String(userInput[..<range.lowerBound])
                .filterIllegalCharacters(in: .decimalDigits.inverted)
        } else {
            userInput = userInput.replacingCharacters(in: range, with: string)
                .filterIllegalCharacters(in: .decimalDigits.inverted)
        }
        var expirationMonth = userInput.prefix(2)
        let expirationYear = userInput.dropFirst(2)
        if expirationMonth.count == 1 && expirationMonth != "0" && expirationMonth != "1" {
            expirationMonth = "0" + expirationMonth
        } else if let month = Int(expirationMonth), month > 12 {
            expirationMonth = "12"
        }
        
        let attributedText = formatedString(
            month: String(expirationMonth),
            year: String(expirationYear),
            attributes: textField.defaultTextAttributes
        )
        return attributedText
    }
    
    private func formatedString(month: String?,
                                year: String?,
                                attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        guard let month, !month.isEmpty else { return NSAttributedString() }
        guard let year, !year.isEmpty else {
            return NSAttributedString(
                string: month,
                attributes: attributes
            )
        }
        let attributedString = NSMutableAttributedString(
            string: "\(month)/\(year)",
            attributes: attributes
        )
        attributedString.addAttribute(
            .kern,
            value: 5,
            range: NSRange(location: month.count - 1, length: 2)
        )
        return attributedString
    }
}
