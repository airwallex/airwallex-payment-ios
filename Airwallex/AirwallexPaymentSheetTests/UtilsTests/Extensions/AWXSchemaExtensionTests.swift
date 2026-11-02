//
//  AWXSchemaExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class AWXSchemaExtensionTests: XCTestCase {

    private var mockSchema: AWXSchema!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let response = AWXGetPaymentMethodTypeResponse.parse(Bundle.dataOfFile("method_type_online_banking")!) as! AWXGetPaymentMethodTypeResponse
        mockSchema = response.schemas.first!
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
        let session = AWXOneOffSession()
        session.countryCode = countryCode
        let params = mockSchema.parametersForHiddenFields(session: session)
        XCTAssertEqual(params[AWXField.Name.countryCode] as? String, countryCode)
        XCTAssertNil(params[AWXField.Name.shipping])
    }

    func testParametersForHiddenFieldsIncludesShippingFromBilling() {
        let schema = schema(hiddenFieldName: AWXField.Name.shipping)
        let billing = AWXPlaceDetails()
        billing.firstName = "Jason"
        billing.lastName = "Wang"
        let session = AWXOneOffSession()
        session.billing = billing

        let params = schema.parametersForHiddenFields(session: session)
        let shipping = params[AWXField.Name.shipping] as? NSDictionary

        XCTAssertTrue(shipping?.isEqual(billing.encodeToJSON()) == true)
    }

    func testParametersForHiddenFieldsOmitsShippingWhenBillingIsNil() {
        let schema = schema(hiddenFieldName: AWXField.Name.shipping)
        let params = schema.parametersForHiddenFields(session: AWXOneOffSession())

        XCTAssertNil(params[AWXField.Name.shipping])
    }

    private func schema(hiddenFieldName: String) -> AWXSchema {
        let field = AWXField()
        field.name = hiddenFieldName
        field.hidden = true
        let schema = AWXSchema()
        schema.fields = [field]
        return schema
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
