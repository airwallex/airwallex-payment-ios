//
//  AddressFieldSpecLabelTests.swift
//  AirwallexPaymentSheetTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import XCTest

class AddressFieldSpecLabelTests: XCTestCase {

    /// Convenience to build a spec without going through `AddressRuleProvider.fields(for:)` so
    /// the test covers the switch independently of any country's rule.
    private func spec(_ kind: AddressFieldKind, nameType: String? = nil) -> AddressFieldSpec {
        AddressFieldSpec(kind: kind, width: .full, nameType: nameType, subdivision: nil, regex: nil)
    }

    /// Localized lookup in the same bundle the production code uses — avoids hard-coding
    /// English so a future translation update doesn't break these tests.
    private func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: .paymentSheet, comment: "")
    }

    // MARK: - Street

    func testStreet_AlwaysResolvesToStreetRegardlessOfNameType() {
        XCTAssertEqual(spec(.street).localizedLabel, localized("Street"))
        // nameType is `nil` for `.street` in production, but the extension shouldn't read it
        // even if a future change populates it.
        XCTAssertEqual(spec(.street, nameType: "prefecture").localizedLabel, localized("Street"))
    }

    // MARK: - State

    func testState_NameTypeMapsToLocalizationKey() {
        let cases: [(String, String)] = [
            ("province", "Province"),
            ("prefecture", "Prefecture"),
            ("do_si", "Do Si"),
            ("county", "County"),
            ("parish", "Parish"),
            ("department", "Department"),
            ("district", "District"),
            ("emirate", "Emirate"),
            ("oblast", "Oblast"),
            ("area", "Area"),
            ("island", "Island"),
        ]
        for (nameType, expectedKey) in cases {
            XCTAssertEqual(spec(.state, nameType: nameType).localizedLabel, localized(expectedKey),
                           "state nameType \(nameType) should map to \(expectedKey)")
        }
    }

    func testState_NameTypeMatchIsCaseInsensitive() {
        XCTAssertEqual(spec(.state, nameType: "PREFECTURE").localizedLabel, localized("Prefecture"))
        XCTAssertEqual(spec(.state, nameType: "Do_Si").localizedLabel, localized("Do Si"))
    }

    func testState_FallsBackToStateForNilOrUnknownNameType() {
        XCTAssertEqual(spec(.state, nameType: nil).localizedLabel, localized("State"))
        XCTAssertEqual(spec(.state, nameType: "unknown_thing").localizedLabel, localized("State"))
        XCTAssertEqual(spec(.state, nameType: "").localizedLabel, localized("State"))
    }

    // MARK: - City

    func testCity_NameTypeMapsToLocalizationKey() {
        let cases: [(String, String)] = [
            ("post_town", "Town"),
            ("district", "District"),
            ("suburb", "Suburb"),
        ]
        for (nameType, expectedKey) in cases {
            XCTAssertEqual(spec(.city, nameType: nameType).localizedLabel, localized(expectedKey),
                           "city nameType \(nameType) should map to \(expectedKey)")
        }
    }

    func testCity_FallsBackToCityForNilOrUnknownNameType() {
        XCTAssertEqual(spec(.city, nameType: nil).localizedLabel, localized("City"))
        XCTAssertEqual(spec(.city, nameType: "unknown").localizedLabel, localized("City"))
    }

    // MARK: - Postcode

    func testPostcode_NameTypeMapsToLocalizationKey() {
        let cases: [(String, String)] = [
            ("zip", "ZIP code"),
            ("pin", "Pin"),
            ("eircode", "Eircode"),
        ]
        for (nameType, expectedKey) in cases {
            XCTAssertEqual(spec(.postcode, nameType: nameType).localizedLabel, localized(expectedKey),
                           "postcode nameType \(nameType) should map to \(expectedKey)")
        }
    }

    func testPostcode_FallsBackToPostalCodeForNilOrUnknownNameType() {
        XCTAssertEqual(spec(.postcode, nameType: nil).localizedLabel, localized("Postal code"))
        XCTAssertEqual(spec(.postcode, nameType: "unknown").localizedLabel, localized("Postal code"))
    }

    // MARK: - End-to-end via AddressRuleProvider

    /// Sanity-check that the spec built by the provider resolves to the expected label —
    /// catches drift between the JSON's `*_name_type` strings and the switch's case strings.
    func testEndToEnd_RuleProviderSpecsResolveToExpectedLabels() {
        let provider = AddressRuleProvider()
        XCTAssertEqual(provider.fields(for: "JP").first { $0.kind == .state }?.localizedLabel,
                       localized("Prefecture"))
        XCTAssertEqual(provider.fields(for: "CN").first { $0.kind == .state }?.localizedLabel,
                       localized("Province"))
        XCTAssertEqual(provider.fields(for: "AE").first { $0.kind == .state }?.localizedLabel,
                       localized("Emirate"))
        XCTAssertEqual(provider.fields(for: "GB").first { $0.kind == .city }?.localizedLabel,
                       localized("Town"))
        XCTAssertEqual(provider.fields(for: "AU").first { $0.kind == .city }?.localizedLabel,
                       localized("Suburb"))
        XCTAssertEqual(provider.fields(for: "IE").first { $0.kind == .postcode }?.localizedLabel,
                       localized("Eircode"))
        XCTAssertEqual(provider.fields(for: "IN").first { $0.kind == .postcode }?.localizedLabel,
                       localized("Pin"))
        XCTAssertEqual(provider.fields(for: "US").first { $0.kind == .postcode }?.localizedLabel,
                       localized("ZIP code"))
        // SC has state_name_type "island" but no sub_keys — still resolves to Island.
        XCTAssertEqual(provider.fields(for: "SC").first { $0.kind == .state }?.localizedLabel,
                       localized("Island"))
    }
}
