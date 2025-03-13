//
//  MaxLengthFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct MaxLengthFormatter: UserInputFormatter {
    
    var maxLength: Int {
        lengthGetter?() ?? fixedLength ?? Int.max
    }
    
    private let fixedLength: Int?
    private let lengthGetter: (() -> Int)?
    private let characterSet: CharacterSet?
    
    init(maxLength: Int,
         characterSet: CharacterSet? = nil) {
        self.fixedLength = maxLength
        self.lengthGetter = nil
        self.characterSet = characterSet
    }
    
    init(maxLengthGetter: @escaping (() -> Int),
         characterSet: CharacterSet? = nil) {
        self.fixedLength = nil
        self.lengthGetter = maxLengthGetter
        self.characterSet = characterSet
    }
    
    func automaticTriggerReturnAction(textField: UITextField) -> Bool {
        guard let selectedRange = textField.selectedTextRange else {
            return false
        }
        let text = textField.text ?? ""
        return selectedRange.end == textField.endOfDocument && text.count >= maxLength
    }
    
    func handleUserInput(_ textField: UITextField, changeCharactersIn range: Range<String.Index>, replacementString string: String) {
        let before = textField.text ?? ""
        let after = before.replacingCharacters(in: range, with: string)
        textField.updateContentAndCusor(plainText: after, maxLength: maxLength)
    }
}
