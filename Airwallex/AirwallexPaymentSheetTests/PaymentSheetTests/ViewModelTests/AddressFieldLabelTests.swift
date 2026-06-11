//
//  AddressFieldLabelTests.swift
//  AirwallexPaymentSheetTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

@testable import AirwallexPaymentSheet
import XCTest

class AddressFieldLabelTests: XCTestCase {

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .paymentSheet, comment: "")
    }

    // MARK: - State

    func testState_DefaultForUnknownAndCommonCountries() {
        let stateCountries = [nil, "AU", "BR", "IN", "MX", "MY", "NG", "US", "VE", "FR", "DE", "ZZ"]
        for code in stateCountries {
            XCTAssertEqual(
                AddressFieldLabel.state(for: code),
                localized("State"),
                "expected default 'State' label for country \(code ?? "nil")"
            )
        }
    }

    func testState_CountrySpecific() {
        XCTAssertEqual(AddressFieldLabel.state(for: "CN"), localized("Province"))
        XCTAssertEqual(AddressFieldLabel.state(for: "JP"), localized("Prefecture"))
        XCTAssertEqual(AddressFieldLabel.state(for: "KR"), localized("Do Si"))
        XCTAssertEqual(AddressFieldLabel.state(for: "IE"), localized("County"))
        XCTAssertEqual(AddressFieldLabel.state(for: "TW"), localized("County"))
        XCTAssertEqual(AddressFieldLabel.state(for: "BB"), localized("Parish"))
        XCTAssertEqual(AddressFieldLabel.state(for: "JM"), localized("Parish"))
        XCTAssertEqual(AddressFieldLabel.state(for: "CO"), localized("Department"))
        XCTAssertEqual(AddressFieldLabel.state(for: "HN"), localized("Department"))
        XCTAssertEqual(AddressFieldLabel.state(for: "NI"), localized("Department"))
        XCTAssertEqual(AddressFieldLabel.state(for: "NR"), localized("District"))
        XCTAssertEqual(AddressFieldLabel.state(for: "AE"), localized("Emirate"))
        XCTAssertEqual(AddressFieldLabel.state(for: "RU"), localized("Oblast"))
        XCTAssertEqual(AddressFieldLabel.state(for: "UA"), localized("Oblast"))
        XCTAssertEqual(AddressFieldLabel.state(for: "HK"), localized("Area"))
        for code in ["BS", "CV", "KI", "KN", "KY", "PF", "SC", "TV"] {
            XCTAssertEqual(AddressFieldLabel.state(for: code), localized("Island"))
        }
    }

    func testState_IsCaseInsensitive() {
        XCTAssertEqual(AddressFieldLabel.state(for: "jp"), localized("Prefecture"))
        XCTAssertEqual(AddressFieldLabel.state(for: "hk"), localized("Area"))
    }

    // MARK: - City

    func testCity_DefaultForUnknownAndCommonCountries() {
        for code in [nil, "US", "CN", "JP", "DE", "ZZ"] {
            XCTAssertEqual(
                AddressFieldLabel.city(for: code),
                localized("City"),
                "expected default 'City' label for country \(code ?? "nil")"
            )
        }
    }

    func testCity_CountrySpecific() {
        XCTAssertEqual(AddressFieldLabel.city(for: "GB"), localized("Town"))
        XCTAssertEqual(AddressFieldLabel.city(for: "NO"), localized("Town"))
        XCTAssertEqual(AddressFieldLabel.city(for: "SE"), localized("Town"))
        XCTAssertEqual(AddressFieldLabel.city(for: "SJ"), localized("Town"))
        XCTAssertEqual(AddressFieldLabel.city(for: "HK"), localized("District"))
        XCTAssertEqual(AddressFieldLabel.city(for: "PE"), localized("District"))
        XCTAssertEqual(AddressFieldLabel.city(for: "TR"), localized("District"))
        XCTAssertEqual(AddressFieldLabel.city(for: "AU"), localized("Suburb"))
    }

    func testCity_IsCaseInsensitive() {
        XCTAssertEqual(AddressFieldLabel.city(for: "gb"), localized("Town"))
        XCTAssertEqual(AddressFieldLabel.city(for: "au"), localized("Suburb"))
    }

    // MARK: - Postcode

    func testPostcode_DefaultForUnknownAndCommonCountries() {
        for code in [nil, "AU", "CN", "JP", "DE", "ZZ"] {
            XCTAssertEqual(
                AddressFieldLabel.postcode(for: code),
                localized("Postal code"),
                "expected default 'Postal code' label for country \(code ?? "nil")"
            )
        }
    }

    func testPostcode_CountrySpecific() {
        XCTAssertEqual(AddressFieldLabel.postcode(for: "US"), localized("ZIP code"))
        XCTAssertEqual(AddressFieldLabel.postcode(for: "GU"), localized("ZIP code"))
        XCTAssertEqual(AddressFieldLabel.postcode(for: "PR"), localized("ZIP code"))
        XCTAssertEqual(AddressFieldLabel.postcode(for: "IN"), localized("Pin"))
        XCTAssertEqual(AddressFieldLabel.postcode(for: "IE"), localized("Eircode"))
    }

    func testPostcode_IsCaseInsensitive() {
        XCTAssertEqual(AddressFieldLabel.postcode(for: "us"), localized("ZIP code"))
        XCTAssertEqual(AddressFieldLabel.postcode(for: "ie"), localized("Eircode"))
    }
}
