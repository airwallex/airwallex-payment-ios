//
//  CVCTextFieldViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/25.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CVCTextFieldViewModel: ErrorHintableTextFieldConfiguring {
    
    var maxLength: Int = 3
    
    // ErrorHintableTextFieldConfiguring
    var errorHint: String? = nil
    
    var text: String? = nil
    
    var attributedText: NSAttributedString? = nil
    
    var isValid: Bool {
        errorHint == nil ? true : false
    }
    
    var textFieldType: AWXTextFieldType? = .CVC
    
    var placeholder: String? = "CVC"
    
    func update(for userInput: String) {
        errorHint = nil
        text = String(userInput.filterIllegalCharacters(in: .decimalDigits.inverted).prefix(maxLength))
    }
    
    func updateForEndEditing() {
        guard let text else {
            errorHint = NSLocalizedString("Security code is required", bundle: .payment, comment: "")
            return
        }
        guard text.count == maxLength else {
            errorHint = NSLocalizedString("Security code is invalid", bundle: .payment, comment: "")
            return
        }
        errorHint = nil
    }
}

//- (nullable NSString *)validationMessageFromCvc:(NSString *)cvc {
//    if (cvc.length > 0) {
//        if (cvc.length == _cvcLength) {
//            return nil;
//        }
//        return NSLocalizedString(@"Security code is invalid", nil);
//    }
//    return NSLocalizedString(@"Security code is required", nil);
//}
