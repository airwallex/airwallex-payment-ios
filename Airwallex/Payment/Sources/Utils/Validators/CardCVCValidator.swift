//
//  CardCVCValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct CardCVCValidator: UserInputValidator {
    
    var maxLength: Int {
        lengthGetter?() ?? fixedLength ?? AWXCardValidator.cvcLength(for: .unknown)
    }
    
    private let fixedLength: Int?
    private let lengthGetter: (() -> Int)?
    
    init(maxLength: Int) {
        self.fixedLength = maxLength
        self.lengthGetter = nil
    }
    
    init(maxLengthGetter: @escaping (() -> Int)) {
        self.fixedLength = nil
        self.lengthGetter = maxLengthGetter
    }
    
    func validateUserInput(_ text: String?) throws {
        let cvcLength = lengthGetter?() ?? fixedLength ?? AWXCardValidator.cvcLength(for: .unknown)
        try AWXCardValidator.validate(cvc: text, requiredLength: cvcLength)
    }
}
