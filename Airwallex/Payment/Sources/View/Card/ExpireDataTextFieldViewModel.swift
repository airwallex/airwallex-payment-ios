//
//  ExpireDataTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//

import Foundation

protocol ErrorHintableTextFieldConfiguring: BasicUserInputViewConfiguring {
    var errorHint: String? { get }
}

class ExpireDataTextFieldViewModel: ErrorHintableTextFieldConfiguring {
    var placeholder: String? = "MM / YY"
    
    var textFieldType: AWXTextFieldType? = .expires
    
    var text: String? {
        attributedText?.string
    }
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var errorHint: String? = nil
    
    func update(for userInput: String) {
        errorHint = nil
        var userInput = userInput.filterIllegalCharacters(in: .decimalDigits.inverted)
        if let text, userInput.count == text.count - 1, text.hasPrefix(userInput), text.last == "/", userInput.count >= 1 {
            // when user deleting "/", we also delete the character before "/"
            userInput = String(userInput.dropLast())
        }
        var expirationMonth = userInput.prefix(2)
        var expirationYear = userInput.dropFirst(2).prefix(2)
        if expirationMonth.count == 1 && expirationMonth != "0" && expirationMonth != "1" {
            expirationMonth = "0" + expirationMonth
        }
        
        attributedText = formatedString(month: String(expirationMonth), year: String(expirationYear))
    }
    
    func updateForEndEditing() {
        guard let text = text, !text.isEmpty else {
            errorHint = NSLocalizedString("Expiry date is required", bundle: .payment, comment: "")
            return
        }
        let components = text.components(separatedBy: "/")
        
        guard components.count == 2,
              let monthString = components.first,
              let month = Int(monthString),
              let yearString = components.last,
              let year = Int(yearString),
              month > 0 && month <= 12 else {
            errorHint = NSLocalizedString("Card’s expiration date is invalid", bundle: .payment, comment: "")
            return
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        let currentYear = calendar.component(.year, from: date) % 100
        let currentMonth = calendar.component(.month, from: date)
         
        guard (year == currentYear && month >= currentMonth) || year > currentYear else {
            errorHint = NSLocalizedString("Card’s expiration date is invalid", bundle: .payment, comment: "")
            return
        }
        errorHint = nil
    }
}

private extension ExpireDataTextFieldViewModel {
    func formatedString(month: String?, year: String?) -> NSAttributedString? {
        guard let month, !month.isEmpty else { return nil }
        guard let year, !year.isEmpty else {
            return NSMutableAttributedString(
                string: month,
                attributes: [.font: UIFont.awxBody, .foregroundColor: UIColor.awxTextPrimary]
            )
        }
        let attributedString = NSMutableAttributedString(
            string: "\(month)/\(year)",
            attributes: [
                .font: UIFont.awxBody,
                .foregroundColor: UIColor.awxTextPrimary,
            ]
        )
        attributedString.addAttribute(
            .kern,
            value: 5,
            range: NSRange(location: month.count - 1, length: 2)
        )
        return attributedString
    }
}
