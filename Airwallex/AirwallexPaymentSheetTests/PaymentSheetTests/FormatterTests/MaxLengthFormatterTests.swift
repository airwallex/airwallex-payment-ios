//
//  MaxLengthFormatterTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//
import XCTest
import UIKit
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class MaxLengthFormatterTests: XCTestCase {

    func testFormatUserInput_withinMaxLength() {
        let formatter = MaxLengthFormatter(maxLength: 5)
        let textField = UITextField()
        textField.text = "123"
        
        let range = textField.text!.endIndex..<textField.text!.endIndex
        textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "4")
        textField.updateContentAndCursor(attributedText: result)
        
        let range2 = textField.text!.endIndex..<textField.text!.endIndex
        let result2 = formatter.formatUserInput(textField, changeCharactersIn: range2, replacementString: "5")
        XCTAssertEqual(result2.string, "12345")
    }

    func testFormatUserInput_exceedsMaxLength() {
        let formatter = MaxLengthFormatter(maxLength: 5)
        let textField = UITextField()
        textField.text = "12345"
        let range = textField.text!.endIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "678")
        textField.updateContentAndCursor(plainText: result.string, maxLength: formatter.maxLength)
        XCTAssertEqual(textField.text, "12345")
    }

    func testFormatUserInput_withCharacterSet() {
        let formatter = MaxLengthFormatter(maxLength: Int.max, characterSet: .decimalDigits)
        let textField = UITextField()
        textField.text = "123"
        let range = textField.text!.endIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "45a")
        XCTAssertEqual(result.string, "12345")
    }

    func testFormatUserInput_dynamicMaxLength() {
        let formatter = MaxLengthFormatter(maxLengthGetter: { return 3 })
        let textField = UITextField()
        textField.text = "12"
        let range = textField.text!.endIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "345")
        textField.updateContentAndCursor(plainText: result.string, maxLength: formatter.maxLength)
        XCTAssertEqual(textField.text, "123")
    }

    func testFormatUserInput_emptyInput() {
        let formatter = MaxLengthFormatter(maxLength: 5)
        let textField = UITextField()
        textField.text = ""
        let range = textField.text!.startIndex..<textField.text!.endIndex
        let result = formatter.formatUserInput(textField, changeCharactersIn: range, replacementString: "12345")
        XCTAssertEqual(result.string, "12345")
    }
}
