//
//  CardExpiryFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct CardExpiryFormatter: UserInputFormatter {
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> (NSAttributedString?, Bool) {
        var userInput = textField.text?.replacingCharacters(in: range, with: string)
            .filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
        if let text = textField.text,
            userInput.count == text.count - 1,
            text.hasPrefix(userInput),
            text.last == "/",
            userInput.count >= 1 {
            // when user deleting "/", we also delete the character before "/"
            userInput = String(userInput.dropLast())
        }
        var expirationMonth = userInput.prefix(2)
        var expirationYear = userInput.dropFirst(2).prefix(2)
        if expirationMonth.count == 1 && expirationMonth != "0" && expirationMonth != "1" {
            expirationMonth = "0" + expirationMonth
        }
        
        let attributedText = formatedString(
            month: String(expirationMonth),
            year: String(expirationYear),
            defaultTextAttributes: textField.defaultTextAttributes
        )
        // wpdebug
        print(attributedText)
        
        let shouldTriggerReturn = shouldTriggerReturn(
            modifiedInput: userInput,
            range: range,
            replacementString: string,
            maxLength: 5
        )
        return (attributedText, shouldTriggerReturn)
    }
    
    func formatedString(month: String?,
                        year: String?,
                        defaultTextAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString? {
        guard let month, !month.isEmpty else { return nil }
        guard let year, !year.isEmpty else {
            return NSAttributedString(
                string: month,
                attributes: defaultTextAttributes
            )
        }
        let attributedString = NSMutableAttributedString(
            string: "\(month)/\(year)",
            attributes: defaultTextAttributes
        )
        attributedString.addAttribute(
            .kern,
            value: 5,
            range: NSRange(location: month.count - 1, length: 2)
        )
        return attributedString
    }
}
