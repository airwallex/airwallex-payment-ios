//
//  AWXCardValidatorExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import AirwallexCore
import XCTest
@testable @_spi(AWX) import AirwallexPayment

class AWXCardValidatorExtensionTests: XCTestCase {
    
    let visaScheme = AWXCardScheme.init(name: AWXCardBrand.visa.rawValue)
    let amexScheme = AWXCardScheme.init(name: AWXCardBrand.amex.rawValue)
    
    func testValidateCardNumber_withSchemes() {
        let validCardNumber = "4111111111111111" // Example of a valid Visa card number
        XCTAssertNoThrow(try AWXCardValidator.validate(number: validCardNumber, supportedSchemes: [visaScheme]))
        XCTAssertThrowsError(try AWXCardValidator.validate(number: validCardNumber, supportedSchemes: [amexScheme]))
    }

    func testValidateCardNumber_invalidLength() {
        let cardNumber = "4234567890123456"
        XCTAssertNoThrow(try AWXCardValidator.validate(number: cardNumber, supportedSchemes: [visaScheme]))
        XCTAssertThrowsError(try AWXCardValidator.validate(number: String(cardNumber.dropLast()), supportedSchemes: [amexScheme]))
        XCTAssertThrowsError(try AWXCardValidator.validate(number: cardNumber + "666", supportedSchemes: [amexScheme]))
    }
    
    func testValidateCardNumber_illegalCharacter() {
        XCTAssertThrowsError(try AWXCardValidator.validate(number: "411111111111111_", supportedSchemes: [visaScheme]))
        XCTAssertThrowsError(try AWXCardValidator.validate(number: "41111111111 111 ", supportedSchemes: [visaScheme]))
    }
    
    func testValidateExpiry() {
        // Valid expiry dates
        XCTAssertNoThrow(try AWXCardValidator.validate(expiryMonth: "12", expiryYear: "2030"))
        XCTAssertNoThrow(try AWXCardValidator.validate(expiryMonth: "12", expiryYear: "2025"))
        
        // Invalid expiry month
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: "13", expiryYear: "2030"))
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: "00", expiryYear: "2030"))
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: nil, expiryYear: "2030"))
        
        // Invalid expiry year
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: "12", expiryYear: "1999"))
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: "12", expiryYear: nil))
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: "12", expiryYear: "30")) // Two-digit year
        
        // Invalid combinations
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: nil, expiryYear: nil))
        XCTAssertThrowsError(try AWXCardValidator.validate(expiryMonth: "00", expiryYear: "1999"))
    }
     
    func testValidateCVC() {
        // Valid CVC
        XCTAssertNoThrow(try AWXCardValidator.validate(cvc: "123", requiredLength: 3))
        XCTAssertNoThrow(try AWXCardValidator.validate(cvc: "1234", requiredLength: 4))
        
        // Invalid CVC - wrong length
        XCTAssertThrowsError(try AWXCardValidator.validate(cvc: "12", requiredLength: 3))
        XCTAssertThrowsError(try AWXCardValidator.validate(cvc: "12345", requiredLength: 4))
        
        // Invalid CVC - nil or empty
        XCTAssertThrowsError(try AWXCardValidator.validate(cvc: nil, requiredLength: 3))
        XCTAssertThrowsError(try AWXCardValidator.validate(cvc: "", requiredLength: 3))
        
        // Invalid CVC - non-numeric characters
        XCTAssertThrowsError(try AWXCardValidator.validate(cvc: "12a", requiredLength: 3))
        XCTAssertThrowsError(try AWXCardValidator.validate(cvc: "1 3", requiredLength: 3))
    }

    func testValidateNameOnCard() {
        // Valid name on card
        XCTAssertNoThrow(try AWXCardValidator.validate(nameOnCard: "John Doe"))
        XCTAssertNoThrow(try AWXCardValidator.validate(nameOnCard: "Jane"))

        // Invalid name on card - nil or empty
        XCTAssertThrowsError(try AWXCardValidator.validate(nameOnCard: nil))
        XCTAssertThrowsError(try AWXCardValidator.validate(nameOnCard: ""))
    }
    
    func testValidateCard() {
        let validCard = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "2030", cvc: "123")
        let invalidSchema = AWXCard(name: "John Doe", cardNumber: "34111111111111111", expiryMonth: "12", expiryYear: "2030", cvc: "123")
        let invalidCardNumber = AWXCard(name: "John Doe", cardNumber: "4111111122223", expiryMonth: "12", expiryYear: "2030", cvc: "123")
        let invalidExpiry = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "13", expiryYear: "2030", cvc: "123")
        let invalidCVC = AWXCard(name: "John Doe", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "2030", cvc: "12")
        let invalidName = AWXCard(name: "", cardNumber: "4111111111111111", expiryMonth: "12", expiryYear: "2030", cvc: "123")
        
        // Valid card
        XCTAssertNoThrow(try AWXCardValidator.validate(
            card: validCard,
            nameRequired: true,
            supportedSchemes: [visaScheme])
        )
        XCTAssertThrowsError(try AWXCardValidator.validate(
            card: invalidSchema,
            nameRequired: true,
            supportedSchemes: [visaScheme])
        )
        
        // Invalid card number
        XCTAssertThrowsError(try AWXCardValidator.validate(
            card: invalidCardNumber,
            nameRequired: true,
            supportedSchemes: [visaScheme])
        )
        
        // Invalid expiry
        XCTAssertThrowsError(try AWXCardValidator.validate(
            card: invalidExpiry,
            nameRequired: true,
            supportedSchemes: [visaScheme])
        )
        
        // Invalid CVC
        XCTAssertThrowsError(try AWXCardValidator.validate(
            card: invalidCVC,
            nameRequired: true,
            supportedSchemes: [visaScheme])
        )
        
        // Invalid name on card
        XCTAssertThrowsError(try AWXCardValidator.validate(
            card: invalidName,
            nameRequired: true,
            supportedSchemes: [visaScheme])
        )
        
        // Valid card without name required
        XCTAssertNoThrow(try AWXCardValidator.validate(
            card: validCard,
            nameRequired: false,
            supportedSchemes: [visaScheme])
        )
        XCTAssertNoThrow(try AWXCardValidator.validate(
            card: invalidName,
            nameRequired: false,
            supportedSchemes: [visaScheme])
        )
    }
    
    func testPossibleBrandTypesForCardNumber() {
        var candidates = AWXCardValidator.possibleBrandTypes(forCardNumber: "6")
        XCTAssertEqual(candidates.count, 3)
        candidates = AWXCardValidator.possibleBrandTypes(forCardNumber: "60")
        XCTAssertEqual(candidates.count, 1)
        XCTAssertEqual(candidates.first, AWXBrandType.discover)
        candidates = AWXCardValidator.possibleBrandTypes(forCardNumber: nil)
        XCTAssertEqual(candidates.count, 7)
        candidates = AWXCardValidator.possibleBrandTypes(forCardNumber: "")
        XCTAssertEqual(candidates.count, 7)
    }
    
    func testLuhnValidation() {
        // Valid card numbers that pass Luhn validation
        let validCardNumbers = [
            // Visa (16 digits)
            "4111111111111111",
            "4012888888881881",
            "4532015112830366",
            
            // Mastercard (16 digits)
            "5555555555554444",
            "5105105105105100",
            "5436031030606378",
            
            // American Express (15 digits)
            "378282246310005",
            "371449635398431",
            "340000000000009",
            
            // Discover (16 digits)
            "6011111111111117",
            "6011000990139424",
            "6011000000000004",
            
            // JCB (16 digits)
            "3530111333300000",
            "3566002020360505",
            "3530000000000003",
            
            // UnionPay (16 digits)
            "6200000000000005",
            "6212345678901232",
            "6250941006528599",
            
            // Diners Club (14 digits)
            "36227206271667",
            "36700102000000",
            "36148900647913"
        ]
        
        // Invalid card numbers that fail Luhn validation
        let invalidCardNumbers = [
            // Visa with incorrect check digit (16 digits)
            "4111111111111112",
            "4012888888881882",
            "4916994372352807",
            
            // Mastercard with incorrect check digit (16 digits)
            "5555555555554443",
            "5105105105105101",
            "5436031030606379",
            
            // American Express with incorrect check digit (15 digits)
            "378282246310006",
            "371449635398432",
            "340000000000008",
            
            // Discover with incorrect check digit (16 digits)
            "6011111111111110",
            "6011000990139425",
            "6011000000000005",
            
            // JCB with incorrect check digit (16 digits)
            "3530111333300001",
            "3566002020360506",
            "3530000000000004",
            
            // UnionPay with incorrect check digit (16 digits)
            "6200000000000006",
            "6212345678901233",
            "6250941006528590",
            
            // Diners Club with incorrect check digit (14 digits)
            "36227206271668",
            "36700102000001",
            "36148900647914",
            
            // Common test cases
            "4242424242424241"  // Test card with wrong check digit
        ]
        
        // Test valid card numbers
        for cardNumber in validCardNumbers {
            let brandType = AWXCardValidator.shared().brand(forCardNumber: cardNumber).type
            if brandType != .unknown {
                let scheme = AWXCardScheme(name: AWXCardValidator.shared().brand(forCardNumber: cardNumber).name)
                XCTAssertNoThrow(try AWXCardValidator.validate(number: cardNumber, supportedSchemes: [scheme]),
                                "Valid card number \(cardNumber) should pass Luhn validation")
            }
        }
        
        // Test invalid card numbers
        for cardNumber in invalidCardNumbers {
            // For this test, we need to ensure the card number is recognized as a valid brand
            // but fails the Luhn check, so we'll use a supported scheme
            let scheme = visaScheme
            
            // First ensure the card number has valid length and format for the scheme
            if AWXCardValidator.shared().isValidCardLength(cardNumber) {
                XCTAssertThrowsError(try AWXCardValidator.validate(number: cardNumber, supportedSchemes: [scheme]),
                                    "Invalid card number \(cardNumber) should fail Luhn validation")
            }
        }
    }
}
