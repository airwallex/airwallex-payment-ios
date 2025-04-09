//
//  CardNumberValidatorTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment
import Core

class CardNumberValidatorTests: XCTestCase {
    
    let visaScheme = AWXCardScheme.init(name: AWXCardBrand.visa.rawValue)
    let amexScheme = AWXCardScheme.init(name: AWXCardBrand.amex.rawValue)
    
    func testValidCardNumber() {
        let validator = CardNumberValidator(supportedCardSchemes: [visaScheme, amexScheme])
        XCTAssertNoThrow(try validator.validateUserInput("4111111111111111")) // Valid Visa card
        XCTAssertNoThrow(try validator.validateUserInput("378282246310005")) // Valid Amex card
    }
    
    func testInvalidCardNumber() {
        let validator = CardNumberValidator(supportedCardSchemes: [visaScheme, amexScheme])
        XCTAssertThrowsError(try validator.validateUserInput("1234567890123456")) // Invalid card number
    }
    
    func testUnsupportedCardScheme() {
        let validator = CardNumberValidator(supportedCardSchemes: [visaScheme])
        XCTAssertThrowsError(try validator.validateUserInput("378282246310005")) // Amex not supported
    }
    
    func testEmptyCardNumber() {
        let validator = CardNumberValidator(supportedCardSchemes: [visaScheme, amexScheme])
        XCTAssertThrowsError(try validator.validateUserInput("")) // Empty input
    }
    
    func testNilCardNumber() {
        let validator = CardNumberValidator(supportedCardSchemes: [visaScheme, amexScheme])
        XCTAssertThrowsError(try validator.validateUserInput(nil)) // Nil input
    }
    
    func testInvalidCharactersInCardNumber() {
        let validator = CardNumberValidator(supportedCardSchemes: [visaScheme, amexScheme])
        XCTAssertThrowsError(try validator.validateUserInput("4111-1111-1111-1111")) // Invalid characters (hyphens)
        XCTAssertThrowsError(try validator.validateUserInput("4111 1111 1111 1111")) // Invalid characters (spaces)
        XCTAssertThrowsError(try validator.validateUserInput("4111abcd1111efgh"))    // Invalid characters (letters)
    }
}
