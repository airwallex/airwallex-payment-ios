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
}
