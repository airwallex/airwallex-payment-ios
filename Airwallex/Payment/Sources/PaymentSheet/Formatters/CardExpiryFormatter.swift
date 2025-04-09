//
//  CardExpiryFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

struct CardExpiryFormatter: UserInputFormatter {
    
    let maxLength = 5
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        var userInput = textField.text?.replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        if let text = textField.text,
           text[range] == "/",
           string != "/" {
            // when user deleting "/", delete all content behind "/"
            userInput = String(text[text.startIndex..<range.lowerBound])
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
        guard maxLength >= attributedText.length else {
            let range = NSRange(location: 0, length: min(maxLength, attributedText.length))
            return attributedText.attributedSubstring(from: range)
        }
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
