//
//  BlockValidatorTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class BlockValidatorTests: XCTestCase {
    
    var validator: BlockValidator!
    override func setUp() {
        super.setUp()
        validator = BlockValidator { input in
            guard let input = input, !input.isEmpty else {
                throw NSError(domain: "TestError", code: 1, userInfo: nil)
            }
        }
    }

    func testValidateUserInput_withValidInput_shouldNotThrowError() {
        XCTAssertNoThrow(try validator.validateUserInput("Valid Input"))
    }
    
    func testValidateUserInput_withNilInput_shouldThrowError() {
        XCTAssertThrowsError(try validator.validateUserInput(nil)) { error in
            XCTAssertEqual((error as NSError).domain, "TestError")
            XCTAssertEqual((error as NSError).code, 1)
        }
    }
    
    func testValidateUserInput_withEmptyInput_shouldThrowError() {
        XCTAssertThrowsError(try validator.validateUserInput("")) { error in
            XCTAssertEqual((error as NSError).domain, "TestError")
            XCTAssertEqual((error as NSError).code, 1)
        }
    }
}
