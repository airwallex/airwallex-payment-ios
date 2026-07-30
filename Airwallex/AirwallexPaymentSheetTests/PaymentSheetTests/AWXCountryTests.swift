//
//  AWXCountryTests.swift
//  AirwallexPaymentSheetTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import AirwallexPayment
@testable import AirwallexPaymentSheet
import XCTest

@MainActor
final class AWXCountryTests: XCTestCase {

    func testInitWithCodeUsesRequestedLanguage() throws {
        let englishCountry = try XCTUnwrap(
            AWXCountry(code: "SG", language: .english)
        )
        let japaneseCountry = try XCTUnwrap(
            AWXCountry(code: "SG", language: .japanese)
        )

        XCTAssertEqual(englishCountry.countryCode, "SG")
        XCTAssertEqual(englishCountry.countryName, "Singapore")
        XCTAssertEqual(japaneseCountry.countryCode, "SG")
        XCTAssertEqual(japaneseCountry.countryName, "シンガポール")
    }

    func testAllCountriesUsesRequestedLanguageAndPreservesCodes() throws {
        let englishCountries = AWXCountry.allCountries(language: .english)
        let japaneseCountries = AWXCountry.allCountries(language: .japanese)

        XCTAssertEqual(
            Set(englishCountries.map(\.countryCode)),
            Set(japaneseCountries.map(\.countryCode))
        )

        let englishJapan = try XCTUnwrap(
            englishCountries.first { $0.countryCode == "JP" }
        )
        let japaneseJapan = try XCTUnwrap(
            japaneseCountries.first { $0.countryCode == "JP" }
        )
        XCTAssertEqual(englishJapan.countryName, "Japan")
        XCTAssertEqual(japaneseJapan.countryName, "日本")
    }

    func testCountryListViewControllerLoadsCountriesUsingConfiguredLanguage() throws {
        let viewController = CountryListViewController()
        viewController.language = .japanese

        viewController.loadViewIfNeeded()

        let singapore = try XCTUnwrap(
            viewController.items.first { $0.countryCode == "SG" }
        )
        XCTAssertEqual(singapore.countryCode, "SG")
        XCTAssertEqual(singapore.countryName, "シンガポール")
    }

    func testShippingControllerResolvesRegionalLanguageOnce() {
        let viewController = AWXShippingViewController(lang: "ja-JP")

        viewController.loadViewIfNeeded()

        XCTAssertEqual(viewController.language, .japanese)
        XCTAssertEqual(
            viewController.title,
            NSLocalizedString("Shipping", bundle: .paymentSheet.language(.japanese), comment: "")
        )
    }

    func testShippingControllerFallbacks() {
        XCTAssertEqual(
            AWXShippingViewController(lang: nil).language,
            resolvePaymentLanguage(nil)
        )
        XCTAssertEqual(
            AWXShippingViewController(lang: "unsupported").language,
            .english
        )
    }
}
