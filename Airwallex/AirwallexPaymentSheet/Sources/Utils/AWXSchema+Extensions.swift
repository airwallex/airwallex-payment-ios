//
//  AWXSchema+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

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
    
    func parametersForHiddenFields(countryCode: String) -> [String: String] {
        let fields = hiddenFields
        var params = [String: String]()
        // flow
        if let flowField = fields.first(where: { $0.name == AWXField.Name.flow }) {
            if flowField.candidates.contains(where: { $0.value == AWXPaymentMethodFlow.app.rawValue }) {
                params[AWXField.Name.flow] = AWXPaymentMethodFlow.app.rawValue
            } else {
                params[AWXField.Name.flow] = flowField.candidates.first?.value
            }
        }
        // osType
        if fields.contains(where: { $0.name == AWXField.Name.osType }) {
            params[AWXField.Name.osType] = "ios"
        }
        // country_code
        if fields.contains(where: { $0.name == AWXField.Name.countryCode }) {
            params[AWXField.Name.countryCode] = countryCode
        }
        
        return params
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
    
    static func phonePrefix(countryCode: String?, currencyCode: String?) -> String? {
        var prefix: String? = nil
        
        if let countryCode {
            do {
                guard let url = Bundle.resource().url(forResource: "CountryCodes", withExtension: "json") else {
                    throw ErrorMessage(rawValue: "no data for country code")
                }
                let data = try Data(contentsOf: url)
                let dict = try JSONDecoder().decode([String: String].self, from: data)
                prefix = dict[countryCode]
            } catch {
                // continue to check currency code
            }
        }
        
        if let prefix { return prefix }
        
        if let currencyCode {
            do {
                guard let url = Bundle.resource().url(forResource: "CurrencyCodes", withExtension: "json") else {
                    throw ErrorMessage(rawValue:"no data for currency code")
                }
                let data = try Data(contentsOf: url)
                let dict = try JSONDecoder().decode([String: String].self, from: data)
                prefix = dict[currencyCode]
            } catch {
                // prefix not found
            }
        }
        return prefix
    }
}
