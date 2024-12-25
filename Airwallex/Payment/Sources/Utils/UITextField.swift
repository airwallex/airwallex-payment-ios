//
//  File.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

extension UITextField {
    func update(for fieldType: AWXTextFieldType) {
        keyboardType = .default
        autocapitalizationType = .sentences
        autocorrectionType = .default
        textContentType = .name
        switch fieldType {
        case .default:
            textContentType = .name
        case .firstName:
            textContentType = .givenName
        case .lastName:
            textContentType = .familyName
        case .nameOnCard:
            if #available(iOS 17.0, *) {
                textContentType = .creditCardName
            } else {
                textContentType = .name
            }
        case .email:
            autocapitalizationType = .none
            autocorrectionType = .no
            textContentType = .emailAddress
        case .phoneNumber:
            textContentType = .telephoneNumber
        case .country:
            textContentType = .countryName
        case .state:
            textContentType = .addressState
        case .city:
            textContentType = .addressCity
        case .street:
            textContentType = .fullStreetAddress
        case .zipcode:
            textContentType = .postalCode
        case .cardNumber:
            textContentType = .creditCardNumber
        case .expires:
            keyboardType = .asciiCapableNumberPad
        case .CVC:
            if #available(iOS 17.0, *) {
                textContentType = .creditCardSecurityCode
            } else {
                // Fallback on earlier versions
                keyboardType = .numberPad
            }
        }
    }
}

extension AWXTextFieldType {
    
    func foo() {
        
    }
}
