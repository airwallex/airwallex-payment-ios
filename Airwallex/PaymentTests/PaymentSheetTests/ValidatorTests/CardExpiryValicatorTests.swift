//
//  CardExpiryValicatorTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import Core
@testable import Payment
import XCTest

class CardExpiryValicatorTests: XCTestCase {
    
    var validator: CardExpiryValidator!
    
    override func setUp() {
        super.setUp()
        validator = CardExpiryValidator()
    }
    
    func testValidExpiryDate() {
        XCTAssertNoThrow(try validator.validateUserInput("12/99"))
    }
    
    func testEmptyExpiryDate() {
        XCTAssertThrowsError(try validator.validateUserInput(""))
        XCTAssertThrowsError(try validator.validateUserInput(nil))
    }
    
    func testInvalidExpiryDateFormat() {
        XCTAssertThrowsError(try validator.validateUserInput("13/25"))
        XCTAssertThrowsError(try validator.validateUserInput("13/25/"))
    }
    
    func testInvalidExpiryDateYear() {
        XCTAssertThrowsError(try validator.validateUserInput("12/199"))
        XCTAssertThrowsError(try validator.validateUserInput("12/00"))
    }
    
    func testInvalidCharacters() {
        XCTAssertThrowsError(try validator.validateUserInput("abc"))
        XCTAssertThrowsError(try validator.validateUserInput("!!/@@"))
        XCTAssertThrowsError(try validator.validateUserInput("  /__"))
    }
}
