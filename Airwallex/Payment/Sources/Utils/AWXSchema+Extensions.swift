//
//  AWXSchema+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

extension AWXSchema {
    var bankField: AWXField? {
        fields.first { field in
            !field.hidden && field.type == AWXField.FieldType.banks && field.uiType == AWXField.UIType.logoList
        }
    }
    
    var uiFields: [AWXField] {
        fields.filter { field in
            guard !field.hidden else { return false }
            return field.uiType == AWXField.UIType.text || field.uiType == AWXField.UIType.email || field.uiType == AWXField.UIType.phone
        }
    }
    
    var hiddenFields: [AWXField] {
        fields.filter { $0.hidden }
    }
}

extension AWXField {
    struct UIType {
        static let text = "text"
        static let email = "email"
        static let phone = "phone"
        static let logoList = "logo_list"
    }
    
    struct FieldType {
        static let banks = "banks"
    }
    
    struct Name {
        static let flow = "flow"
        static let osType = "osType"
        static let countryCode = "country_code"
        static let bankName = "bank_name"
    }
    
    var textFieldType: AWXTextFieldType {
        Self.textFieldType(uiType: uiType)
    }
    
    static func textFieldType(uiType: String) -> AWXTextFieldType {
        switch uiType {
        case UIType.email:
            return .email
        case UIType.phone:
            return .phoneNumber
        default:
            return .default
        }
    }
}
