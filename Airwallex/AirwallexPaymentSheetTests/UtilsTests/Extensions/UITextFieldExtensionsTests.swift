//
//  UITextFieldExtensionsTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class UITextFieldExtensionsTests: XCTestCase {
    
    func testUpdateForFieldType() {
        let textField = UITextField()
        textField.update(for: .default)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        XCTAssertEqual(textField.textContentType, .none)

        textField.update(for: .email)
        XCTAssertEqual(textField.keyboardType, .emailAddress)
        XCTAssertEqual(textField.autocapitalizationType, .none)
        XCTAssertEqual(textField.autocorrectionType, .no)
        XCTAssertEqual(textField.textContentType, .emailAddress)
        
        textField.update(for: .phoneNumber)
        XCTAssertEqual(textField.keyboardType, .phonePad)
        XCTAssertEqual(textField.textContentType, .telephoneNumber)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .firstName)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .givenName)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .lastName)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .familyName)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .country)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .countryName)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .state)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .addressState)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .city)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .addressCity)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .street)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.textContentType, .fullStreetAddress)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .zipcode)
        XCTAssertEqual(textField.keyboardType, .asciiCapableNumberPad)
        XCTAssertEqual(textField.textContentType, .postalCode)
        
        textField.update(for: .cardNumber)
        XCTAssertEqual(textField.keyboardType, .asciiCapableNumberPad)
        XCTAssertEqual(textField.textContentType, .creditCardNumber)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .nameOnCard)
        XCTAssertEqual(textField.keyboardType, .default)
        XCTAssertEqual(textField.autocapitalizationType, .words)
        XCTAssertEqual(textField.autocorrectionType, .default)
        if #available(iOS 17.0, *) {
            XCTAssertEqual(textField.textContentType, .creditCardName)
        } else {
            XCTAssertEqual(textField.textContentType, .name)
        }
        
        textField.update(for: .expires)
        XCTAssertEqual(textField.keyboardType, .asciiCapableNumberPad)
        XCTAssertEqual(textField.textContentType, .none)
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
        
        textField.update(for: .CVC)
        XCTAssertEqual(textField.keyboardType, .asciiCapableNumberPad)
        if #available(iOS 17.0, *) {
            XCTAssertEqual(textField.textContentType, .creditCardSecurityCode)
        } else {
            XCTAssertEqual(textField.textContentType, .none)
        }
        XCTAssertEqual(textField.autocapitalizationType, .sentences)
        XCTAssertEqual(textField.autocorrectionType, .default)
    }
    
    func testUpdateWithoutDelegate() {
        let textField = UITextField()
        let delegate = MockTextFieldDelegate()
        textField.delegate = delegate
        
        textField.updateWithoutDelegate { field in
            field.text = "Test"
            XCTAssertNil(field.delegate)
        }
        
        XCTAssertEqual(textField.text, "Test")
        XCTAssertTrue(textField.delegate === delegate)
    }
    
    func testUpdateContentAndCursorAttributedText() {
        let textField = UITextField()
        let attributedText1 = NSAttributedString(string: "Test", attributes: textField.defaultTextAttributes)
        textField.updateContentAndCursor(attributedText: attributedText1)
        XCTAssertEqual(textField.attributedText, attributedText1)
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument))
        
        // update selection range and call updateContentAndCursor(attributedText:) again and assert cursor position
        var cursorPosition = textField.position(from: textField.beginningOfDocument, offset: 2)!
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
        let attributedText2 = NSAttributedString(string: "TestTest", attributes: textField.defaultTextAttributes)
        textField.updateContentAndCursor(attributedText: attributedText2)
        XCTAssertEqual(textField.attributedText, attributedText2)
        cursorPosition = textField.position(from: cursorPosition, offset: attributedText2.length - attributedText1.length)!
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: cursorPosition, to: cursorPosition))
    }

    func testUpdateContentAndCursorAttributedTextWithMaxLength() {
        let textField = UITextField()
        let attributedText1 = NSAttributedString(string: "Test", attributes: textField.defaultTextAttributes)
        textField.updateContentAndCursor(attributedText: attributedText1, maxLength: 4)
        XCTAssertEqual(textField.attributedText, attributedText1)
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument))
        
        // update selection range and call updateContentAndCursor(attributedText:) again and assert cursor position
        var cursorPosition = textField.position(from: textField.beginningOfDocument, offset: 2)!
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
        let attributedText2 = NSAttributedString(string: "TestTest", attributes: textField.defaultTextAttributes)
        textField.updateContentAndCursor(attributedText: attributedText2, maxLength: 4)
        XCTAssertEqual(textField.attributedText, NSAttributedString(string: "Test", attributes: textField.defaultTextAttributes))
        cursorPosition = textField.position(from: cursorPosition, offset: attributedText2.length - attributedText1.length) ?? textField.endOfDocument
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: cursorPosition, to: cursorPosition))
    }
    
    func testUpdateContentAndCursorPlainText() {
        let textField = UITextField()
        let text1 = "Test"
        textField.updateContentAndCursor(plainText: text1)
        XCTAssertEqual(textField.text, text1)
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument))
        
        let text2 = "TestTest"
        // update selection range and call updateContentAndCursor(plainText:) again and assert cursor position
        var cursorPosition = textField.position(from: textField.beginningOfDocument, offset: 2)!
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
        textField.updateContentAndCursor(plainText: text2)
        XCTAssertEqual(textField.text, text2)
        cursorPosition = textField.position(from: cursorPosition, offset: text2.count - text1.count)!
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: cursorPosition, to: cursorPosition))
    }
    
    func testUpdateContentAndCursorPlainTextWithMaxLength() {
        let textField = UITextField()
        let text1 = "Test"
        textField.updateContentAndCursor(plainText: text1, maxLength: 4)
        XCTAssertEqual(textField.text, text1)
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument))
        
        let text2 = "TestTest"
        // update selection range and call updateContentAndCursor(plainText:) again and assert cursor position
        var cursorPosition = textField.position(from: textField.beginningOfDocument, offset: 2)!
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
        textField.updateContentAndCursor(plainText: text2, maxLength: 4)
        XCTAssertEqual(textField.text, "Test")
        cursorPosition = textField.position(from: cursorPosition, offset: text2.count - text1.count) ?? textField.endOfDocument
        XCTAssertEqual(textField.selectedTextRange, textField.textRange(from: cursorPosition, to: cursorPosition))
    }
    
    func testTextDidBeginEditingPublisher() {
        let textField = UITextField()
        let expectation = expectation(description: "textDidBeginEditingPublisher")
        
        let cancellable = textField.textDidBeginEditingPublisher.sink { _ in
            expectation.fulfill()
        }
        
        NotificationCenter.default.post(name: UITextField.textDidBeginEditingNotification, object: textField)
        
        waitForExpectations(timeout: 1, handler: nil)
        cancellable.cancel()
    }
    
    func testTextDidEndEditingPublisher() {
        let textField = UITextField()
        let expectation = self.expectation(description: "textDidEndEditingPublisher")
        
        let cancellable = textField.textDidEndEditingPublisher.sink { _ in
            expectation.fulfill()
        }
        
        NotificationCenter.default.post(name: UITextField.textDidEndEditingNotification, object: textField)
        
        waitForExpectations(timeout: 1, handler: nil)
        cancellable.cancel()
    }
    
    func testTextDidChangePublisher() {
        let textField = UITextField()
        let expectation = self.expectation(description: "textDidChangePublisher")
        
        let cancellable = textField.textDidChangePublisher.sink { _ in
            expectation.fulfill()
        }
        
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: textField)
        
        waitForExpectations(timeout: 1, handler: nil)
        cancellable.cancel()
    }
}

class MockTextFieldDelegate: NSObject, UITextFieldDelegate {}
