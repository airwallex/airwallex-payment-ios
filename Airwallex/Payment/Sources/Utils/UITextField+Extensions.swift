//
//  File.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

extension UITextField {
    func update(for fieldType: AWXTextFieldType) {
        keyboardType = .default
        autocapitalizationType = .sentences
        autocorrectionType = .default
        textContentType = .name
        switch fieldType {
        case .default:
            textContentType = nil
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
            keyboardType = .emailAddress
        case .phoneNumber:
            textContentType = .telephoneNumber
            keyboardType = .phonePad
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
            keyboardType = .asciiCapableNumberPad
        case .cardNumber:
            textContentType = .creditCardNumber
            keyboardType = .asciiCapableNumberPad
        case .expires:
            if #available(iOS 17.0, *) {
                textContentType = .creditCardExpiration
            }
            keyboardType = .asciiCapableNumberPad
        case .CVC:
            if #available(iOS 17.0, *) {
                textContentType = .creditCardSecurityCode
            }
            keyboardType = .asciiCapableNumberPad
        @unknown default:
            fatalError()
        }
    }
    
    func updateWithoutDelegate(_ updates: (UITextField) -> Void) {
        let tmp = delegate
        delegate = nil
        updates(self)
        delegate = tmp
    }
}

extension UITextField {
    
    var textDidBeginEditingPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification, object: self)
            .eraseToAnyPublisher()
    }
    
    var textDidEndEditingPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification, object: self)
            .eraseToAnyPublisher()
    }
    
    var textDidChangePublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .eraseToAnyPublisher()
    }
}

