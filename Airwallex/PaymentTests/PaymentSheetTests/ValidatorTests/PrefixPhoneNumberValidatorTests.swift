//
//  PrefixPhoneNumberValidatorTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class PrefixPhoneNumberValidatorTests: XCTestCase {

    func testValidateUserInput_withPhoneNumberWithoutPrefix() {
        let validator = PrefixPhoneNumberValidator(prefix: nil)
        XCTAssertNoThrow(try validator.validateUserInput("14155552671"))
        XCTAssertNoThrow(try validator.validateUserInput("+4414155552671"))
        XCTAssertNoThrow(try validator.validateUserInput("+44"))
        
        XCTAssertThrowsError(try validator.validateUserInput("+4"))
        XCTAssertThrowsError(try validator.validateUserInput("+141555526711234567890")) // Too long
        XCTAssertThrowsError(try validator.validateUserInput("+1415555abcde")) // Invalid characters
    }
    
    func testValidateUserInput_withPhoneNumberWithPrefix() {
        let validator = PrefixPhoneNumberValidator(prefix: "+44")
        XCTAssertNoThrow(try validator.validateUserInput("+14155552671"))
        XCTAssertNoThrow(try validator.validateUserInput("14155552671"))
        
        XCTAssertThrowsError(try validator.validateUserInput("+44"))
        XCTAssertThrowsError(try validator.validateUserInput("+4"))
        XCTAssertThrowsError(try validator.validateUserInput("+141555526711234567890")) // Too long
        XCTAssertThrowsError(try validator.validateUserInput("+1415555abcde")) // Invalid characters
    }
}
