//
//  BlockValidator.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/7.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct BlockValidator: UserInputValidator {
    
    let block: (String?) throws -> Void
    
    func validateUserInput(_ text: String?) throws {
        try block(text)
    }
}
