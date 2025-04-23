//
//  MaxLengthFormatter.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

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
    
    func formatUserInput(_ textField: UITextField,
                         changeCharactersIn range: Range<String.Index>,
                         replacementString string: String) -> NSAttributedString {
        var userInput = (textField.text ?? "").replacingCharacters(in: range, with: string)
        if let characterSet {
            userInput = userInput.filterIllegalCharacters(in: characterSet.inverted)
        }
        let attributedText = NSAttributedString(
            string: userInput,
            attributes: textField.defaultTextAttributes
        )
        return attributedText
    }
}
