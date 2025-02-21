//
//  CardExpireTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//

import Foundation

class CardExpireTextFieldViewModel: BaseTextFieldConfiguring {
    
    init(returnActionhandler: ((UITextField) -> Void)? = nil) {
        self.returnActionHandler = returnActionhandler
    }
    
    // MARK: - BaseTextFieldConfiguring
    var isEnabled: Bool = true
    
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
    
    var returnKeyType: UIReturnKeyType = .default
    
    var returnActionHandler: ((UITextField) -> Void)?
    
    func handleTextShouldChange(textField: UITextField, range: Range<String.Index>, replacementString string: String) -> Bool {
        var userInput = textField.text?.replacingCharacters(in: range, with: string).filterIllegalCharacters(in: .decimalDigits.inverted) ?? ""
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
        if (expirationMonth.count + expirationYear.count == 4) {
            returnActionHandler?(textField)
        }
        return false
    }
    
    func handleDidEndEditing() {
        guard let text = text, !text.isEmpty else {
            errorHint = NSLocalizedString("Expiry date is required", bundle: .payment, comment: "")
            return
        }
        let components = text.components(separatedBy: "/")
        do {
            try AWXCardValidator.validate(expiryMonth: components.first, expiryYear: components.last)
            errorHint = nil
        } catch {
            guard let error = error as? String else { return }
            errorHint = error
        }
    }
}

private extension CardExpireTextFieldViewModel {
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
