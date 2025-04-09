//
//  StringExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class StringExtensionTests: XCTestCase {
    func testFilterIllegalCharacters() {
        let originalString = "Hello, World!"
        let filteredString = originalString.filterIllegalCharacters(in: .punctuationCharacters)
        XCTAssertEqual(filteredString, "Hello World")
        
        let stringWithNumbers = "123-456-7890"
        let filteredNumbers = stringWithNumbers.filterIllegalCharacters(in: .decimalDigits)
        XCTAssertEqual(filteredNumbers, "--")
        
        let stringWithWhitespace = "Hello World"
        let filteredWhitespace = stringWithWhitespace.filterIllegalCharacters(in: .whitespaces)
        XCTAssertEqual(filteredWhitespace, "HelloWorld")
    }

    func testIsValidEmail() {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertFalse("test.example.com".isValidEmail)
        XCTAssertFalse("test@.com".isValidEmail)
        XCTAssertFalse("test@com".isValidEmail)
    }

    func testIsValidE164PhoneNumber() {
        XCTAssertTrue("+1234567890".isValidE164PhoneNumber)
        XCTAssertTrue("1234567890".isValidE164PhoneNumber)
        XCTAssertFalse("+1 234 567 890".isValidE164PhoneNumber)
        XCTAssertFalse("123-456-7890".isValidE164PhoneNumber)
    }

    func testIsValidCountryCode() {
        XCTAssertTrue("US".isValidCountryCode)
        XCTAssertTrue("CN".isValidCountryCode)
        XCTAssertFalse("XX".isValidCountryCode)
        XCTAssertFalse("USA".isValidCountryCode)
    }

    func testTrimmed() {
        XCTAssertEqual("  Hello  ".trimmed, "Hello")
        XCTAssertEqual("\nHello\n".trimmed, "Hello")
        XCTAssertEqual("Hello".trimmed, "Hello")
        XCTAssertEqual("  Hello World  ".trimmed, "Hello World")
    }

    func testAsError() {
        let message = "error message!"
        let error = message.asError()
        XCTAssertEqual(error.localizedDescription, message)
        XCTAssertEqual(error.rawValue, message)
        XCTAssertEqual(ErrorMessage(rawValue: message).localizedDescription, error.localizedDescription)
    }
}
