//
//  ErrorMessage.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct ErrorMessage: Error, RawRepresentable, LocalizedError {
    let rawValue: String
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    var errorDescription: String? {
        rawValue
    }
}
