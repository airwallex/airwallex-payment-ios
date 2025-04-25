//
//  AWXModelExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
import AirwallexCore

class AWXModelExtensionTests: XCTestCase {
    func testSupportedBrands() {
        let expectedBrands: [AWXBrandType] = [.visa, .mastercard, .amex, .unionPay, .JCB, .dinersClub, .discover]
        XCTAssertEqual(AWXBrandType.allAvailable, expectedBrands, "Supported brands do not match the expected values.")
    }
    
    func testAWXCardInitializer() {
        let name = "John Doe"
        let cardNumber = "4111 1111 1111 1111"
        let expiryMonth = "4"
        let expiryYear = "2025"
        let cvc = "123"
        
        let card = AWXCard(
            name: name,
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cvc: cvc
        )
        
        XCTAssertEqual(card.name, name, "Card name does not match.")
        XCTAssertEqual(card.number, "4111111111111111", "Card number does not match.")
        XCTAssertEqual(card.expiryMonth, "4", "Expiry month does not match.")
        XCTAssertEqual(card.expiryYear, "2025", "Expiry year does not match.")
        XCTAssertEqual(card.cvc, cvc, "CVC does not match.")
    }
    
    func testAWXCardBrandAll() {
        let expectedBrands: [AWXCardBrand] = [
            .visa,
            .mastercard,
            .amex,
            .JCB,
            .dinersClub,
            .discover,
            .unionPay
        ]
        XCTAssertEqual(AWXCardBrand.allAvailable, expectedBrands, "Card brands do not match the expected values.")
    }

    func testAWXCardSchemeAllAvailable() {
        let allBrands = AWXCardBrand.allAvailable.map { $0.rawValue }
        let allSchema = AWXCardScheme.allAvailable.map { $0.name }
        XCTAssertTrue(Set(allBrands).isSubset(of: allSchema))
        XCTAssertTrue(Set(allSchema).isSubset(of: allBrands))
    }

    func testAWXCardSchemeInitializer() {
        let name = "visa"
        let cardScheme = AWXCardScheme(name: name)
        XCTAssertEqual(cardScheme.name, name, "Card scheme name does not match the expected value.")
    }
}
