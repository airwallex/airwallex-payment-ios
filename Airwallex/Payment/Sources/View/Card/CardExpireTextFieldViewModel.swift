//
//  CardExpireTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//

import Foundation

class CardExpireTextFieldViewModel: InfoCollectorTextFieldViewModel {
    
    init(reconfigureHandler: @escaping ReconfigureHandler) {
        super.init(
            textFieldType: .expires,
            placeholder: "MM / YY",
            customInputValidator: CardExpiryValidator(),
            reconfigureHandler: reconfigureHandler
        )
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let range = Range(range, in: textField.text ?? "") else {
            return false
        }
        defer {
            //  update text
            reconfigureHandler(self, false)
        }
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
        print(attributedText)
        if (expirationMonth.count + expirationYear.count == 4) {
            returnActionHandler?(textField)
        }
        return false
    }
}
// TODO: text formatter for cvc
private extension CardExpireTextFieldViewModel {
    func formatedString(month: String?, year: String?) -> NSAttributedString? {
        guard let month, !month.isEmpty else { return nil }
        guard let year, !year.isEmpty else {
            return NSMutableAttributedString(
                string: month,
                attributes: [.font: UIFont.awxFont(.body2), .foregroundColor: UIColor.awxColor(.textPrimary)]
            )
        }
        let attributedString = NSMutableAttributedString(
            string: "\(month)/\(year)",
            attributes: [
                .font: UIFont.awxFont(.body2),
                .foregroundColor: UIColor.awxColor(.textPrimary),
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
