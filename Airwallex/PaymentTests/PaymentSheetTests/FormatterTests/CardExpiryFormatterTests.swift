//
//  CardExpiryFormatterTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/1.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class CardExpiryFormatterTests: XCTestCase {

    func testAutomaticTriggerReturnAction_WhenTextFieldAtEndAndMaxLengthReached_ShouldReturnTrue() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        textField.text = "12/34"
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
        let result = formatter.shouldAutomaticTriggerReturnAction(textField: textField)
        XCTAssertTrue(result)
    }
    
    func testAutomaticTriggerReturnAction_WhenTextFieldNotAtEnd_ShouldReturnFalse() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        textField.text = "12/34"
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.beginningOfDocument)
        let result = formatter.shouldAutomaticTriggerReturnAction(textField: textField)
        XCTAssertFalse(result)
    }
    
    func testFormatUserInput_WhenDeletingSlash_ShouldRemoveContentAfterSlash() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        textField.text = "12/34"
        let range = textField.text!.range(of: "/")!
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "")
        XCTAssertEqual(result.string, "12")
    }
    
    func testFormatUserInput_WhenMonthExceeds12_ShouldCapTo12() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        let range = textField.text!.startIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "15")
        XCTAssertEqual(result.string, "12")
    }
    
    func testFormatUserInput_WhenSingleDigitMonth_ShouldPrefixWithZero() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        let range = textField.text!.startIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "3")
        XCTAssertEqual(result.string, "03")
    }
    
    func testFormatUserInput_WhenValidMonthAndYearProvided_ShouldFormatCorrectly() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        textField.text = "12"
        let range = textField.text!.endIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "34")
        XCTAssertEqual(result.string, "12/34")
    }
    
    func testFormatedString_WhenOnlyMonthProvided_ShouldReturnMonthOnly() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        let range = textField.text!.startIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "12")
        XCTAssertEqual(result.string, "12")
    }
    
    func testFormatedString_WhenEmptyMonth_ShouldReturnEmptyString() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        let range = textField.text!.startIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "")
        XCTAssertEqual(result.string, "")
    }

    func testFilterInvalidCharacters_ShouldRemoveNonNumericCharacters() {
        let formatter = CardExpiryFormatter()
        let textField = UITextField()
        var range = textField.text!.endIndex..<textField.text!.endIndex
        var result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "1abc3zz")
        XCTAssertEqual(result.string, "12")
        
        textField.updateContentAndCursor(attributedText: result)
        range = textField.text!.endIndex..<textField.text!.endIndex
        result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "zz99")
        XCTAssertEqual(result.string, "12/99")
    }
}
