//
//  StringExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable @_spi(AWX) import AirwallexPayment

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
        XCTAssertTrue("test@example.company".isValidEmail)
        
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
    
    // MARK: - JWT Payload Tests
    
    func testPayloadOfJWTWithValidToken() throws {
        // This is a manually constructed JWT token with a valid payload
        // Format: header.payload.signature (signature can be anything for this test)
        // Payload is {"sub":"1234567890","name":"Test User","iat":1516239022}
        let validJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlRlc3QgVXNlciIsImlhdCI6MTUxNjIzOTAyMn0.signature"
        
        let payload = try validJWT.payloadOfJWT()
        
        XCTAssertEqual(payload["sub"] as? String, "1234567890")
        XCTAssertEqual(payload["name"] as? String, "Test User")
        XCTAssertEqual(payload["iat"] as? Int, 1516239022)
    }
    
    func testPayloadOfJWTWithInvalidFormat() {
        // Test JWT without enough components (missing payload and signature)
        let invalidJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        
        XCTAssertThrowsError(try invalidJWT.payloadOfJWT()) { error in
            guard let jwtError = error as? String.JWTError else {
                XCTFail("Expected String.JWTError but got \(error)")
                return
            }
            XCTAssertEqual(jwtError, .invalidFormat)
            XCTAssertNotNil(jwtError.errorDescription)
        }
    }
    
    func testPayloadOfJWTWithInvalidBase64() {
        // Test JWT with invalid base64 in payload
        // Valid header, invalid base64 for payload, and any signature
        let invalidBase64JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.!!!invalid_base64!!!.signature"
        
        XCTAssertThrowsError(try invalidBase64JWT.payloadOfJWT()) { error in
            guard let jwtError = error as? String.JWTError else {
                XCTFail("Expected String.JWTError but got \(error)")
                return
            }
            XCTAssertEqual(jwtError, .invalidBase64)
            XCTAssertNotNil(jwtError.errorDescription)
        }
    }
    
    func testPayloadOfJWTWithInvalidJSON() {
        // Test JWT with valid base64 but invalid JSON in payload
        // The payload encodes the string "not_json" which isn't valid JSON
        let invalidJSONJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.bm90X2pzb24=.signature"
        
        XCTAssertThrowsError(try invalidJSONJWT.payloadOfJWT()) { error in
            guard let jwtError = error as? String.JWTError else {
                XCTFail("Expected String.JWTError but got \(error)")
                return
            }
            XCTAssertEqual(jwtError, .invalidJSON)
            XCTAssertNotNil(jwtError.errorDescription)
        }
    }
    
    func testPayloadOfJWTWithNonDictionaryJSON() {
        // Test JWT with valid base64 but JSON that's an array, not a dictionary
        // The payload encodes the array [1,2,3] which isn't a dictionary
        let arrayJSONJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.WzEsMiwzXQ==.signature"
        
        XCTAssertThrowsError(try arrayJSONJWT.payloadOfJWT()) { error in
            guard let jwtError = error as? String.JWTError else {
                XCTFail("Expected String.JWTError but got \(error)")
                return
            }
            XCTAssertEqual(jwtError, .invalidJSON)
            XCTAssertNotNil(jwtError.errorDescription)
        }
    }
    
    func testPayloadOfJWTWithBase64Padding() throws {
        // Test JWT with payload that requires base64 padding
        // Payload: {"a":"b"}
        let jwtWithPadding = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhIjoiYiJ9.signature"
        
        let payload = try jwtWithPadding.payloadOfJWT()
        
        XCTAssertEqual(payload["a"] as? String, "b")
    }
}
