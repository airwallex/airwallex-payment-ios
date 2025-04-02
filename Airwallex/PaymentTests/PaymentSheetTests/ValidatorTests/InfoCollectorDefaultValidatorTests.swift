//
//  InfoCollectorDefaultValidatorTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
import Core
@testable import Payment

class InfoCollectorDefaultValidatorTests: XCTestCase {

    func testValidateUserInput_firstName() {
        let validator = InfoCollectorDefaultValidator(fieldType: .firstName, isRequired: true, title: "First Name")
        XCTAssertNoThrow(try validator.validateUserInput("John"))
    }
    
    func testValidateUserInput_lastName() {
        let validator = InfoCollectorDefaultValidator(fieldType: .firstName, isRequired: true, title: "First Name")
        XCTAssertNoThrow(try validator.validateUserInput("aaa"))
    }

    func testValidateUserInput_country() {
        let validator = InfoCollectorDefaultValidator(fieldType: .country, isRequired: true, title: "Country")
        XCTAssertNoThrow(try validator.validateUserInput("Australia"))
    }

    func testValidateUserInput_street() {
        let validator = InfoCollectorDefaultValidator(fieldType: .street, isRequired: true, title: "Street")
        XCTAssertNoThrow(try validator.validateUserInput("123 Main St"))
    }
    
    func testValidateUserInput_state() {
        let validator = InfoCollectorDefaultValidator(fieldType: .state, isRequired: true, title: "State")
        XCTAssertNoThrow(try validator.validateUserInput("state"))
    }
    
    func testValidateUserInput_city() {
        let validator = InfoCollectorDefaultValidator(fieldType: .city, isRequired: true, title: "City")
        XCTAssertNoThrow(try validator.validateUserInput("city"))
    }
    
    func testValidateUserInput_nameOnCard() {
        let validator = InfoCollectorDefaultValidator(fieldType: .nameOnCard, isRequired: true, title: "Name on card")
        XCTAssertNoThrow(try validator.validateUserInput("name"))
    }
    
    func testValidateUserInput_email() {
        let validator = InfoCollectorDefaultValidator(fieldType: .email, isRequired: true, title: "Email")
        XCTAssertNoThrow(try validator.validateUserInput("test@example.com"))
        XCTAssertThrowsError(try validator.validateUserInput("invalid-email"))
    }

    func testValidateUserInput_phoneNumber() {
        let validator = InfoCollectorDefaultValidator(fieldType: .phoneNumber, isRequired: true, title: "Phone Number")
        XCTAssertNoThrow(try validator.validateUserInput("+1234567890"))
        XCTAssertThrowsError(try validator.validateUserInput("1234567890987654321"))
        XCTAssertThrowsError(try validator.validateUserInput("abc123456789"))
    }


    func testValidateUserInput_allFieldTypes_required() {
        let fieldTypes: [AWXTextFieldType] = [
            .firstName, .lastName, .email, .phoneNumber, .country, .state, .city, .street, .zipcode, .cardNumber, .nameOnCard, .expires, .CVC
        ]
        
        for fieldType in fieldTypes {
            let validator = InfoCollectorDefaultValidator(fieldType: fieldType, isRequired: true, title: "\(fieldType)")
            XCTAssertThrowsError(try validator.validateUserInput(nil))
            XCTAssertThrowsError(try validator.validateUserInput(""))
            XCTAssertThrowsError(try validator.validateUserInput(" "))
        }
    }

    func testValidateUserInput_allFieldTypes_optional() {
        let fieldTypes: [AWXTextFieldType] = [
            .firstName, .lastName, .email, .phoneNumber, .country, .state, .city, .street, .zipcode, .cardNumber, .nameOnCard, .expires, .CVC
        ]
        
        for fieldType in fieldTypes {
            let validator = InfoCollectorDefaultValidator(fieldType: fieldType, isRequired: false, title: "\(fieldType)")
            XCTAssertNoThrow(try validator.validateUserInput(nil))
            XCTAssertNoThrow(try validator.validateUserInput(""))
        }
    }
}
