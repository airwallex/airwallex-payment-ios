//
//  InformativeUserInputViewModel.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

class InformativeUserInputViewModel: InformativeUserInputViewConfiguring {
    var title: String?
    
    var errorHint: String?
    
    var text: String?
    
    var attributedText: NSAttributedString?
    
    var isValid: Bool
    
    var textFieldType: AWXTextFieldType?
    
    var placeholder: String?
    
    func update(for userInput: String) {
        guard !userInput.isEmpty else {
            text = nil
            return
        }
        text = userInput
    }
    
    func updateForEndEditing() {
        // do nothing
    }
    
    init(title: String? = nil,
         errorHint: String? = nil,
         text: String? = nil,
         attributedText: NSAttributedString? = nil,
         isValid: Bool = true,
         textFieldType: AWXTextFieldType? = .default,
         placeholder: String? = nil) {
        self.title = title
        self.errorHint = errorHint
        self.text = text
        self.attributedText = attributedText
        self.isValid = isValid
        self.textFieldType = textFieldType
        self.placeholder = placeholder
    }
}
