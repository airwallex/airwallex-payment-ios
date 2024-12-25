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
    
    var text: String? = nil
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var errorHint: String? = nil
    
    func update(for userInput: String) {
        errorHint = nil
        var expirationMonth = userInput.prefix(2)
        var expirationYear = userInput.dropFirst(2)
        if !expirationYear.isEmpty {
            expirationYear = expirationYear.prefix(2)
        }
        if expirationMonth.count == 1 && expirationMonth != "0" && expirationMonth != "1" {
            expirationMonth = "0" + expirationMonth
        }
        text = expirationMonth + "/" + expirationYear
    }
    
    func updateForEndEditing() {
        guard let text = text, !text.isEmpty else {
            errorHint = NSLocalizedString("Expiry date is required", bundle: .payment, comment: "")
            return
        }
        let components = text.components(separatedBy: "/")
        
        guard components.count == 2,
              let month = components.first as? Int,
              let year = components.last as? Int,
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
