//
//  File.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/24.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

#if canImport(AirwallexCore)
import AirwallexCore
#endif

extension UITextField {
    func update(for fieldType: AWXTextFieldType) {
        keyboardType = .default
        autocapitalizationType = .sentences
        autocorrectionType = .default
        textContentType = .none
        switch fieldType {
        case .default:
            textContentType = nil
        case .firstName:
            textContentType = .givenName
        case .lastName:
            textContentType = .familyName
        case .nameOnCard:
            autocapitalizationType = .words
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
            keyboardType = .asciiCapable
        case .cardNumber:
            textContentType = .creditCardNumber
            keyboardType = .asciiCapableNumberPad
        case .expires:
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
    
    func updateContentAndCursor(attributedText: NSAttributedString,
                                maxLength: Int = Int.max) {
        let before = self.attributedText ?? NSAttributedString()
        let acceptRange = NSRange(location: 0, length: min(maxLength, attributedText.length))
        let after = attributedText.attributedSubstring(from: acceptRange)
        guard let selectedRange = selectedTextRange else {
            // no need to update cursor
            self.attributedText = after
            return
        }
        self.attributedText = after
        if before != attributedText {
            var cursorPosition: Int
            if attributedText.length >= before.length {
                cursorPosition = offset(from: beginningOfDocument, to: selectedRange.start)
            } else {
                cursorPosition = offset(from: beginningOfDocument, to: selectedRange.end)
            }
            let newCursorPosition = position(
                from: beginningOfDocument,
                offset: cursorPosition + (attributedText.length - before.length)
            )
            
            if let newCursorPosition {
                selectedTextRange = textRange(
                    from: newCursorPosition,
                    to: newCursorPosition
                )
            } else {
                selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
            }
        } else {
            // no need to update
        }
    }
    
    func updateContentAndCursor(plainText: String,
                               maxLength: Int = Int.max) {
        let before = text ?? ""
        var after = plainText
        if let endIndex = after.index(after.startIndex, offsetBy: maxLength, limitedBy: after.endIndex) {
            after = String(after[..<endIndex])
        }
        guard let selectedRange = selectedTextRange else {
            text = after
            return
        }
        text = after
        if plainText != before {
            let cursorPosition = offset(from: beginningOfDocument, to: selectedRange.start)
            let newCursorPosition = position(
                from: beginningOfDocument,
                offset: cursorPosition + (plainText.count - before.count)
            )
            
            if let newCursorPosition {
                selectedTextRange = textRange(
                    from: newCursorPosition,
                    to: newCursorPosition
                )
            } else {
                selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
            }
        } else {
            // no need to update
        }
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

