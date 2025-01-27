//
//  ConfigTextFieldViewModel.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/20.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class ConfigTextFieldViewModel {
    let fieldKey: String
    let displayName: String
    var text: String?
    var caption: String?
    
    init(displayName: String,
         fieldKey: String = "",
         text: String? = nil,
         caption: String? = nil) {
        self.fieldKey = fieldKey
        self.displayName = displayName
        self.text = text
        self.caption = caption
    }
}
