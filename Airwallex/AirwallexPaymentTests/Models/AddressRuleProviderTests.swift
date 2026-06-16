//
//  AddressRuleProviderTests.swift
//  AirwallexPaymentTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
import XCTest

final class AddressRuleProviderTests: XCTestCase {

    private var provider: AddressRuleProvider!

    override func setUp() {
        super.setUp()
        provider = AddressRuleProvider()
    }

    // MARK: - rule(for:)

    func testRule_LooksUpUppercased() {
        XCTAssertNotNil(provider.rule(for: "US"))
        XCTAssertNotNil(provider.rule(for: "us"))
        XCTAssertNotNil(provider.rule(for: "Us"))
    }

    func testRule_ReturnsNilForUnknownOrEmpty() {
        XCTAssertNil(provider.rule(for: ""))
        XCTAssertNil(provider.rule(for: nil))
        XCTAssertNil(provider.rule(for: "ZZ"))
    }

    // MARK: - fields(for:)

    func testFields_USHasFourFieldsWithMiddleHalfPair() {
        let fields = provider.fields(for: "US")
        XCTAssertEqual(fields.map(\.kind), [.street, .state, .city, .postcode])
        XCTAssertEqual(fields.map(\.width), [.full, .half, .half, .full])
        XCTAssertNotNil(fields[1].subdivision, "US state should be a dropdown")
        XCTAssertNotNil(fields[3].regex, "US postcode should have a regex")
    }

    func testFields_JPSkipsCity() {
        // JP fmt declares %A %S %Z (no %C) — three fields, state+postcode form the half pair.
        let fields = provider.fields(for: "JP")
        XCTAssertEqual(fields.map(\.kind), [.street, .state, .postcode])
        XCTAssertEqual(fields.map(\.width), [.full, .half, .half])
    }

    func testFields_GBSkipsState() {
        // GB fmt has no %S — city+postcode form the half pair.
        let fields = provider.fields(for: "GB")
        XCTAssertEqual(fields.map(\.kind), [.street, .city, .postcode])
        XCTAssertEqual(fields.map(\.width), [.full, .half, .half])
    }

    func testFields_HKHasNoPostcode() {
        let fields = provider.fields(for: "HK")
        XCTAssertEqual(fields.map(\.kind), [.street, .state, .city])
        XCTAssertNotNil(fields[1].subdivision, "HK 'Area' state should be a dropdown")
    }

    func testFields_AEHasOnlyStreetAndState() {
        let fields = provider.fields(for: "AE")
        XCTAssertEqual(fields.map(\.kind), [.street, .state])
        XCTAssertEqual(fields.map(\.width), [.full, .full], "Two fields → both full width, no half pair")
        XCTAssertNotNil(fields[1].subdivision, "AE emirate should be a dropdown")
    }

    func testFields_AXLiteralTextInFmtIgnored() {
        // AX's fmt contains literal "AX-" and "ÅLAND"; the %([ACSZ]) parser must not turn those
        // into spurious fields.
        let fields = provider.fields(for: "AX")
        XCTAssertEqual(fields.map(\.kind), [.street, .city, .postcode])
    }

    func testFields_SCStateIsFreeTextWhenNoSubKeys() {
        // SC declares state_name_type "island" but no sub_keys — render as free-text.
        let fields = provider.fields(for: "SC")
        XCTAssertEqual(fields.first { $0.kind == .state }?.nameType, "island")
        XCTAssertNil(fields.first { $0.kind == .state }?.subdivision)
    }

    func testFields_FallbackWhenFmtMissing() {
        // Countries like AO have only `"country": "AO"` — no fmt — fall back to [street, city].
        let fields = provider.fields(for: "AO")
        XCTAssertEqual(fields.map(\.kind), [.street, .city])
        XCTAssertEqual(fields.map(\.width), [.full, .full])
    }

    func testFields_NameTypeMappedPerKind() {
        XCTAssertEqual(provider.fields(for: "JP").first { $0.kind == .state }?.nameType, "prefecture")
        XCTAssertEqual(provider.fields(for: "IE").first { $0.kind == .postcode }?.nameType, "eircode")
        XCTAssertEqual(provider.fields(for: "GB").first { $0.kind == .city }?.nameType, "post_town")
        XCTAssertEqual(provider.fields(for: "US").first { $0.kind == .postcode }?.nameType, "zip")
        XCTAssertNil(provider.fields(for: "US").first { $0.kind == .street }?.nameType,
                     "Street should never carry a name_type hint")
    }

    func testFields_ZipRegexValidatesExamples() {
        guard let usRegex = provider.fields(for: "US").first(where: { $0.kind == .postcode })?.regex else {
            return XCTFail("US should have a zip regex")
        }
        let valid = ["94110", "94110-1234", "10001"]
        let invalid = ["abc", "9411", "94110-12", ""]
        let fullRange = { (s: String) in NSRange(s.startIndex..., in: s) }
        for s in valid {
            XCTAssertNotNil(usRegex.firstMatch(in: s, range: fullRange(s)), "expected match: \(s)")
        }
        for s in invalid {
            XCTAssertNil(usRegex.firstMatch(in: s, range: fullRange(s)), "expected no match: \(s)")
        }
    }

    // MARK: - [SubdivisionOption].option(matching:)

    func testOptionMatching_ByValueAndLabel_CaseInsensitive() {
        let options = [
            SubdivisionOption(value: "CA", label: "California"),
            SubdivisionOption(value: "NY", label: "New York"),
        ]
        XCTAssertEqual(options.option(matching: "CA")?.value, "CA")
        XCTAssertEqual(options.option(matching: "ca")?.value, "CA")
        XCTAssertEqual(options.option(matching: "California")?.value, "CA")
        XCTAssertEqual(options.option(matching: "  california  ")?.value, "CA")
        XCTAssertEqual(options.option(matching: "NEW YORK")?.value, "NY")
    }

    func testAllRules_SubArraysHaveConsistentCount() {
        // Every rule that has `sub_keys` should also have matching counts for `sub_labels` and
        // (when present) `sub_latin_names`. A mismatch in `address.json` would silently drop
        // labels or Latin names off the end of the array — the test pins the data file.
        var inconsistencies: [String] = []
        for code in provider.allCountryCodes {
            guard let rule = provider.rule(for: code), let keys = rule.subKeys else { continue }
            if let labels = rule.subLabels, labels.count != keys.count {
                inconsistencies.append("\(code): sub_labels (\(labels.count)) ≠ sub_keys (\(keys.count))")
            }
            if let latin = rule.subLatinNames, latin.count != keys.count {
                inconsistencies.append("\(code): sub_latin_names (\(latin.count)) ≠ sub_keys (\(keys.count))")
            }
        }
        XCTAssertTrue(inconsistencies.isEmpty,
                      "address.json sub-array count mismatches:\n - \(inconsistencies.joined(separator: "\n - "))")
    }

    func testOptionMatching_ByLatinName_CaseInsensitive() {
        // Non-Latin sub_keys with Latin transliterations — Latin-only input matches via latinName.
        let options = [
            SubdivisionOption(value: "أبو ظبي", label: "أبو ظبي — Abu Dhabi", latinName: "Abu Dhabi"),
            SubdivisionOption(value: "إمارة دبيّ", label: "دبي — Dubai", latinName: "Dubai"),
        ]
        XCTAssertEqual(options.option(matching: "Abu Dhabi")?.value, "أبو ظبي")
        XCTAssertEqual(options.option(matching: "abu dhabi")?.value, "أبو ظبي")
        XCTAssertEqual(options.option(matching: "  DUBAI  ")?.value, "إمارة دبيّ")
        XCTAssertNil(options.option(matching: "Cairo"), "non-listed Latin name should not match")
    }

    func testOptionMatching_NoMatchReturnsNil() {
        let options = [SubdivisionOption(value: "CA", label: "California")]
        XCTAssertNil(options.option(matching: "Foo"))
        XCTAssertNil(options.option(matching: ""))
        XCTAssertNil(options.option(matching: nil))
        XCTAssertNil(options.option(matching: "   "))
    }

    // MARK: - isValid(_:)

    /// Builds an AWXAddress with the four common fields prefilled. Override per test.
    private func address(countryCode: String?,
                         street: String? = "1 Main St",
                         state: String? = "",
                         city: String? = "Springfield",
                         postcode: String? = "") -> AWXAddress {
        let address = AWXAddress()
        address.countryCode = countryCode
        address.street = street
        address.state = state
        address.city = city
        address.postcode = postcode
        return address
    }

    func testIsValid_RejectsMissingOrInvalidCountryCode() {
        XCTAssertFalse(provider.isValid(address(countryCode: nil)))
        XCTAssertFalse(provider.isValid(address(countryCode: "")))
        XCTAssertFalse(provider.isValid(address(countryCode: "ZZ")))
    }

    func testIsValid_USRequiresAllFourFieldsAndDropdownMatch() {
        let valid = address(countryCode: "US", state: "California", postcode: "94110")
        XCTAssertTrue(provider.isValid(valid))

        let bySubKey = address(countryCode: "US", state: "CA", postcode: "94110")
        XCTAssertTrue(provider.isValid(bySubKey))

        // Garbage state — dropdown country requires a known option.
        let badState = address(countryCode: "US", state: "Foo", postcode: "94110")
        XCTAssertFalse(provider.isValid(badState))

        // Bad postcode — fails regex.
        let badPostcode = address(countryCode: "US", state: "CA", postcode: "abc")
        XCTAssertFalse(provider.isValid(badPostcode))

        // Missing field.
        let missingCity = address(countryCode: "US", state: "CA", city: "", postcode: "94110")
        XCTAssertFalse(provider.isValid(missingCity))
    }

    func testIsValid_HKHasNoPostcodeRequirement() {
        let valid = address(countryCode: "HK", state: "Kowloon", city: "Tsim Sha Tsui", postcode: nil)
        XCTAssertTrue(provider.isValid(valid), "HK rule has no postcode in fmt")
    }

    func testIsValid_GBHasNoStateRequirement() {
        let valid = address(countryCode: "GB", state: nil, city: "London", postcode: "EC1Y 8SY")
        XCTAssertTrue(provider.isValid(valid), "GB rule has no state in fmt")
    }

    func testIsValid_AEStateRequiredAsDropdown() {
        // AE has bilingual sub_labels ("أبو ظبي — Abu Dhabi") plus a sub_latin_names array
        // ("Abu Dhabi"). `option(matching:)` accepts any of the three forms.
        let byLabel = address(countryCode: "AE", state: "أبو ظبي — Abu Dhabi", city: nil, postcode: nil)
        XCTAssertTrue(provider.isValid(byLabel))

        let bySubKey = address(countryCode: "AE", state: "أبو ظبي", city: nil, postcode: nil)
        XCTAssertTrue(provider.isValid(bySubKey))

        // Latin-only form now matches via `sub_latin_names`.
        let byLatinName = address(countryCode: "AE", state: "Abu Dhabi", city: nil, postcode: nil)
        XCTAssertTrue(provider.isValid(byLatinName))

        let badState = address(countryCode: "AE", state: "Mars", city: nil, postcode: nil)
        XCTAssertFalse(provider.isValid(badState))
    }

    func testIsValid_SCStateAcceptsFreeText() {
        // SC has state in fmt but no sub_keys — any non-empty string passes the state check.
        let valid = address(countryCode: "SC", state: "Mahé", city: "Victoria", postcode: nil)
        XCTAssertTrue(provider.isValid(valid))
    }

    func testIsValid_JPNoCityRequiredAndPostcodeRegex() {
        // JP fmt is %A %S %Z — city is not required. State is a dropdown (prefectures).
        // Postcode regex: \d{3}-?\d{4}.
        let validKey = address(countryCode: "JP", state: "東京都", city: nil, postcode: "154-0023")
        XCTAssertTrue(provider.isValid(validKey), "JP rule has no city field")

        // Sub_label form also valid.
        let validLabel = address(countryCode: "JP", state: "東京都 — Tokyo", city: nil, postcode: "1540023")
        XCTAssertTrue(provider.isValid(validLabel))

        // Bad postcode (letters) — rejected.
        let badPostcode = address(countryCode: "JP", state: "東京都", city: nil, postcode: "abc")
        XCTAssertFalse(provider.isValid(badPostcode))

        // Missing required field (street) — rejected even though city isn't required.
        let missingStreet = address(countryCode: "JP", street: "", state: "東京都", city: nil, postcode: "154-0023")
        XCTAssertFalse(provider.isValid(missingStreet))
    }

    func testIsValid_AXIgnoresLiteralTextInFmt() {
        // AX's fmt is "%O%n%N%n%A%nAX-%Z %C%nÅLAND" — literal "AX-" and "ÅLAND" must not be
        // treated as fields. Valid spec is [street, city, postcode]; postcode regex `22\d{3}`.
        let valid = address(countryCode: "AX", state: nil, city: "Mariehamn", postcode: "22100")
        XCTAssertTrue(provider.isValid(valid), "literal text in fmt must not introduce required fields")

        let badPostcode = address(countryCode: "AX", state: nil, city: "Mariehamn", postcode: "abcde")
        XCTAssertFalse(provider.isValid(badPostcode))
    }

    func testIsValid_AOEmptyFmtFallbackRequiresStreetAndCity() {
        // AO has only `"country": "AO"` — no fmt. The fallback rule is [street, city] both required.
        let valid = address(countryCode: "AO", state: nil, city: "Luanda", postcode: nil)
        XCTAssertTrue(provider.isValid(valid), "AO fallback requires only street and city")

        let missingCity = address(countryCode: "AO", state: nil, city: "", postcode: nil)
        XCTAssertFalse(provider.isValid(missingCity))

        let missingStreet = address(countryCode: "AO", street: "", state: nil, city: "Luanda", postcode: nil)
        XCTAssertFalse(provider.isValid(missingStreet))
    }
}
