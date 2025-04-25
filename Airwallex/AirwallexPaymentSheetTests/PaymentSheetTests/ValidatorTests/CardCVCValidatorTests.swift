//
//  CardCVCValidatorTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import AirwallexCore

class CardCVCValidatorTests: XCTestCase {
    
    private var mockValidator: CardCVCValidator!
    
    enum CardCVCValidationError: Error, Equatable {
        case emptyInput
        case exceedsMaxLength
        case invalidCharacters
    }
    
    override func setUp() {
        super.setUp()
        mockValidator = CardCVCValidator(maxLength: 3)
    }
    
    func testMaxLength() {
        let fixedLengthValidator = CardCVCValidator(maxLength: 3)
        XCTAssertEqual(fixedLengthValidator.maxLength, 3, "Fixed length validator should have maxLength of 3")
        
        let dynamicLengthValidator = CardCVCValidator(maxLengthGetter: { return 4 })
        XCTAssertEqual(dynamicLengthValidator.maxLength, 4, "Dynamic length validator should have maxLength of 4")
        
        let visaValidator = CardCVCValidator(cardName: AWXCardBrand.visa.rawValue)
        XCTAssertEqual(visaValidator.maxLength, 3)
        
        let amexValidator = CardCVCValidator(cardName: AWXCardBrand.amex.rawValue)
        XCTAssertEqual(amexValidator.maxLength, 4)
    }
    
    func testFormatUserInput() {
        let textField = UITextField()
        textField.defaultTextAttributes = [.font: UIFont.systemFont(ofSize: 14)]
        
        // Test case 1: Valid input within maxLength
        textField.text = "12"
        let result1 = mockValidator.formatUserInput(
            textField,
            changeCharactersIn: textField.text!.endIndex..<textField.text!.endIndex,
            replacementString: "3"
        )
        XCTAssertEqual(result1.string, "123", "Formatted input should match expected value within maxLength")
        
        // Test case 2: Input exceeding maxLength
        textField.text = "1234"
        let result2 = mockValidator.formatUserInput(
            textField,
            changeCharactersIn: textField.text!.endIndex..<textField.text!.endIndex,
            replacementString: "5"
        )
        textField.updateContentAndCursor(attributedText: result2, maxLength: mockValidator.maxLength)
        XCTAssertEqual(textField.text, "123", "Formatted input should not exceed maxLength")
        
        // Test case 3: Input with illegal characters
        textField.text = "12a"
        let result3 = mockValidator.formatUserInput(
            textField,
            changeCharactersIn: textField.text!.endIndex..<textField.text!.endIndex,
            replacementString: "b"
        )
        XCTAssertEqual(result3.string, "12", "Formatted input should filter out illegal characters")
        
        // Test case 4: Empty input
        textField.text = ""
        let result4 = mockValidator.formatUserInput(
            textField,
            changeCharactersIn: textField.text!.startIndex..<textField.text!.startIndex,
            replacementString: "1"
        )
        XCTAssertEqual(result4.string, "1", "Formatted input should handle empty input correctly")
    }
    
    func testValidateUserInput() {
        // Test case 1: Valid CVC input
        XCTAssertNoThrow(try mockValidator.validateUserInput("123"), "Valid CVC input should not throw an error")
        
        // Test case 2: Empty input
        XCTAssertThrowsError(try mockValidator.validateUserInput(""), "Empty input should throw an error")
        
        // Test case 3: Input exceeding maxLength
        XCTAssertThrowsError(try mockValidator.validateUserInput("12345"), "Input exceeding maxLength should throw an error")
        
        // Test case 4: Input with illegal characters
        XCTAssertThrowsError(try mockValidator.validateUserInput("12a"), "Input with illegal characters should throw an error")
        
        // Test case 5: Nil input
        XCTAssertThrowsError(try mockValidator.validateUserInput(nil), "Nil input should throw an error")
    }
    
}
