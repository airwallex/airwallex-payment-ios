//
//  AWXSchemaExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable @_spi(AWX) import AirwallexPayment
@testable import AirwallexPaymentSheet
import AirwallexCore

class AWXSchemaExtensionTests: XCTestCase {

    private var mockSchema: AWXSchema!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSchema = Bundle.decode(file: "method_type_online_banking")!
    }
    
    func testBankField() {
        let bankField = mockSchema.bankField
        XCTAssertNotNil(bankField)
        XCTAssertEqual(bankField?.type, AWXField.FieldType.banks)
        XCTAssertEqual(bankField?.uiType, AWXField.UIType.logoList)
        XCTAssertFalse(bankField?.hidden ?? true)
    }

    func testUIFields() {
        let uiFields = mockSchema.uiFields
        XCTAssertFalse(uiFields.isEmpty)
        XCTAssert(uiFields.count == 3)
        for field in uiFields {
            XCTAssertFalse(field.hidden)
            XCTAssertTrue([AWXField.UIType.text, AWXField.UIType.email, AWXField.UIType.phone].contains(field.uiType))
        }
    }

    func testHiddenFields() {
        let hiddenFields = mockSchema.hiddenFields
        XCTAssertFalse(hiddenFields.isEmpty)
        XCTAssert(hiddenFields.count == 1)
        let countryField = hiddenFields.first!
        XCTAssertTrue(countryField.hidden)
    }

    func testParametersForHiddenFields() {
        let countryCode = "AU"
        let params = mockSchema.parametersForHiddenFields(countryCode: countryCode)
        XCTAssertEqual(params[AWXField.Name.countryCode], countryCode)
    }

    func testAWXFieldTextFieldType() {
        XCTAssertEqual(AWXField.textFieldType(uiType: AWXField.UIType.email), .email)
        XCTAssertEqual(AWXField.textFieldType(uiType: AWXField.UIType.phone), .phoneNumber)
        XCTAssertEqual(AWXField.textFieldType(uiType: "unknown"), .default)
    }

    func testAWXFieldPhonePrefix() {
        let mockCountryCode = "SG"
        let mockCurrencyCode = "SGD"
        
        let prefixForCountry = AWXField.phonePrefix(countryCode: mockCountryCode, currencyCode: nil)
        XCTAssertEqual(prefixForCountry, "+65") // Assuming "+65" is the prefix for "SG" in the test data
        
        let prefixForCurrency = AWXField.phonePrefix(countryCode: nil, currencyCode: mockCurrencyCode)
        XCTAssertEqual(prefixForCurrency, "+65") // Assuming "+65" is the prefix for "SGD" in the test data
        
        let prefixForUnknown = AWXField.phonePrefix(countryCode: "XX", currencyCode: "XXX")
        XCTAssertNil(prefixForUnknown)
    }
}
