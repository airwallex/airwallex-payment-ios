//
//  SchemaFieldValidatorTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/7/30.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
import AirwallexCore
@_spi(AWX) import AirwallexPayment
@testable import AirwallexPaymentSheet

class SchemaFieldValidatorTests: XCTestCase {
    
    // MARK: - Helper Methods
    
    private func createField(name: String, displayName: String, regex: String? = nil, maxLength: Int = 0) -> AWXField? {
        let json: [String: Any] = [
            "name": name,
            "display_name": displayName,
            "validations": [
                "regex": regex as Any,
                "max": maxLength
            ]
        ]
        
        return AWXField.decode(fromJSON: json) as? AWXField
    }
    
    // MARK: - Initialization Tests
    
    func testInit_withValidRegexParameter() {
        // Create a field with regex validation
        guard let field = createField(name: "test_field", displayName: "Test Field", regex: "^[a-zA-Z]+$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator with valid parameters
        let validator = SchemaFieldValidator(field: field)
        
        // Assert validator is not nil
        XCTAssertNotNil(validator)
    }
    
    func testInit_withMaxLengthOnly() {
        // Create a field with max length only
        guard let field = createField(name: "test_field", displayName: "Test Field", maxLength: 10) else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator with valid parameters
        let validator = SchemaFieldValidator(field: field)
        
        // Assert validator is not nil
        XCTAssertNotNil(validator)
    }
    
    func testInit_withInvalidParameters() {
        // Create a field without regex or max length
        guard let field = createField(name: "test_field", displayName: "Test Field") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator with invalid parameters
        let validator = SchemaFieldValidator(field: field)
        
        // Assert validator is nil
        XCTAssertNil(validator)
    }
    
    // MARK: - Regex Validation Tests
    
    func testValidateUserInput_withValidRegex() {
        // Create a field with regex for letters only
        guard let field = createField(name: "letters_only", displayName: "Letters Only", regex: "^[a-zA-Z]+$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test with valid input
        XCTAssertNoThrow(try validator.validateUserInput("ValidInput"))
        XCTAssertNoThrow(try validator.validateUserInput("abcDEF"))
    }
    
    func testValidateUserInput_withInvalidRegex() {
        // Create a field with regex for letters only
        guard let field = createField(name: "letters_only", displayName: "Letters Only", regex: "^[a-zA-Z]+$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test with invalid input (contains numbers)
        XCTAssertThrowsError(try validator.validateUserInput("Invalid123")) { error in
            // Verify error message
            if let errorMessage = error as? ErrorMessage {
                XCTAssertEqual(errorMessage.rawValue, "Invalid letters only")
            } else {
                XCTFail("Expected ErrorMessage type")
            }
        }
        
        // Test with invalid input (contains special characters)
        XCTAssertThrowsError(try validator.validateUserInput("Invalid@#$"))
    }
    
    func testValidateUserInput_withComplexRegex() {
        // Create a field with regex for email format
        guard let field = createField(name: "email", displayName: "Email", regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test with valid email
        XCTAssertNoThrow(try validator.validateUserInput("test@example.com"))
        XCTAssertNoThrow(try validator.validateUserInput("user.name+tag@domain.co.uk"))
        
        // Test with invalid email
        XCTAssertThrowsError(try validator.validateUserInput("invalid-email"))
        XCTAssertThrowsError(try validator.validateUserInput("test@"))
        XCTAssertThrowsError(try validator.validateUserInput("test@domain"))
    }
    
    // MARK: - Max Length Validation Tests
    
    func testValidateUserInput_withMaxLength() {
        // Create a field with max length
        guard let field = createField(name: "short_text", displayName: "Short Text", maxLength: 5) else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test with valid input (within max length)
        XCTAssertNoThrow(try validator.validateUserInput("12345"))
        XCTAssertNoThrow(try validator.validateUserInput("abc"))
        
        // Test with invalid input (exceeds max length)
        XCTAssertThrowsError(try validator.validateUserInput("123456"))
        XCTAssertThrowsError(try validator.validateUserInput("abcdef"))
    }
    
    func testValidateUserInput_withRegexAndMaxLength() {
        // Create a field with both regex and max length
        guard let field = createField(name: "digits", displayName: "Digits", regex: "^[0-9]+$", maxLength: 5) else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test with valid input (matches regex and within max length)
        XCTAssertNoThrow(try validator.validateUserInput("12345"))
        XCTAssertNoThrow(try validator.validateUserInput("123"))
        
        // Test with invalid input (matches regex but exceeds max length)
        XCTAssertThrowsError(try validator.validateUserInput("123456"))
        
        // Test with invalid input (within max length but doesn't match regex)
        XCTAssertThrowsError(try validator.validateUserInput("abc12"))
    }
    
    // MARK: - Error Message Tests
    
    func testErrorMessage_withFieldDisplayName() {
        // Create a field with regex and display name
        guard let field = createField(name: "custom_field", displayName: "Custom Field", regex: "^[a-zA-Z]+$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test error message includes field display name
        XCTAssertThrowsError(try validator.validateUserInput("123")) { error in
            if let errorMessage = error as? ErrorMessage {
                XCTAssertEqual(errorMessage.rawValue, "Invalid custom field")
            } else {
                XCTFail("Expected ErrorMessage type")
            }
        }
    }
    
    func testErrorMessage_withoutFieldDisplayName() {
        // Create a field with regex but no display name
        guard let field = createField(name: "no_display_name", displayName: "", regex: "^[a-zA-Z]+$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test error message uses default "input" text
        XCTAssertThrowsError(try validator.validateUserInput("123")) { error in
            if let errorMessage = error as? ErrorMessage {
                XCTAssertEqual(errorMessage.rawValue, "Invalid user input")
            } else {
                XCTFail("Expected ErrorMessage type")
            }
        }
    }
    
    // MARK: - Nil Input Tests
    
    func testValidateUserInput_withNilInput() {
        // Create a field with regex
        guard let field = createField(name: "test_field", displayName: "Test Field", regex: "^[a-zA-Z]+$") else {
            XCTFail("Failed to create AWXField")
            return
        }
        
        // Initialize validator
        guard let validator = SchemaFieldValidator(field: field) else {
            XCTFail("Failed to create SchemaFieldValidator")
            return
        }
        
        // Test with nil input
        XCTAssertThrowsError(try validator.validateUserInput(nil))
    }
}
