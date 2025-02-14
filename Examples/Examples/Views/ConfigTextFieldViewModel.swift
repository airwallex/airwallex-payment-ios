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
    
    var textDidChange: ((String?) -> Void)?
    var textDidEndEditing: ((String?) -> Void)?
    
    init(displayName: String,
         fieldKey: String = "",
         text: String? = nil,
         caption: String? = nil,
         textDidChange: ((String?) -> Void)? = nil,
         textDidEndEditing: ((String?) -> Void)? = nil) {
        self.fieldKey = fieldKey
        self.displayName = displayName
        self.text = text
        self.caption = caption
        self.textDidChange = textDidChange
        self.textDidEndEditing = textDidEndEditing
    }
}
