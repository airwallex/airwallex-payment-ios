//
//  AWXAddressExtensionTests.swift
//  PaymentTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
import XCTest

/// Rule-driven validation smoke tests against `AddressRuleProvider.isValid(_:)`. The heavy
/// lifting lives in `AddressRuleProviderTests`; this file exercises the same paths through a
/// shared provider instance and confirms the public deprecated `AWXAddress.isComplete` shim
/// stays in lock-step.
class AWXAddressExtensionTests: XCTestCase {

    private let ruleProvider = AddressRuleProvider()

    private func address(countryCode: String?,
                         street: String? = "1 Main St",
                         state: String? = "",
                         city: String? = "Sydney",
                         postcode: String? = "") -> AWXAddress {
        let address = AWXAddress()
        address.countryCode = countryCode
        address.street = street
        address.state = state
        address.city = city
        address.postcode = postcode
        return address
    }

    func testIsValid_AUWithValidSubKeyAndPostcode() {
        let valid = address(countryCode: "AU", state: "NSW", postcode: "2060")
        XCTAssertTrue(ruleProvider.isValid(valid))
    }

    func testIsValid_AURejectsBadPostcodeAndBadState() {
        XCTAssertFalse(ruleProvider.isValid(address(countryCode: "AU", state: "Bogus", postcode: "2060")),
                       "dropdown state must map to an option")
        XCTAssertFalse(ruleProvider.isValid(address(countryCode: "AU", state: "NSW", postcode: "abc")),
                       "postcode must match the country regex")
    }

    func testIsValid_HKAcceptsMissingPostcode() {
        let valid = address(countryCode: "HK", state: "Kowloon", city: "Tsim Sha Tsui", postcode: nil)
        XCTAssertTrue(ruleProvider.isValid(valid), "HK rule has no postcode field")
    }

    func testIsValid_GBAcceptsMissingState() {
        let valid = address(countryCode: "GB", state: nil, city: "London", postcode: "EC1Y 8SY")
        XCTAssertTrue(ruleProvider.isValid(valid), "GB rule has no state field")
    }

    func testIsValid_RejectsMissingCountry() {
        XCTAssertFalse(ruleProvider.isValid(address(countryCode: nil)))
        XCTAssertFalse(ruleProvider.isValid(address(countryCode: "ZZ")))
    }

    @available(*, deprecated, message: "Exercising deprecated `isComplete` shim on purpose.")
    func testIsComplete_DeprecatedShimMirrorsRuleProviderIsValid() {
        let valid = address(countryCode: "AU", state: "NSW", postcode: "2060")
        let invalid = address(countryCode: nil)
        XCTAssertEqual(valid.isComplete, ruleProvider.isValid(valid))
        XCTAssertEqual(invalid.isComplete, ruleProvider.isValid(invalid))
    }
}
