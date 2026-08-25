//
//  AWXPaymentLanguageTests.swift
//  AirwallexPaymentSheetTests
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import XCTest

final class AWXPaymentLanguageTests: XCTestCase {

    func testPaymentLanguageRawValues() {
        let identifiers: [(AWXPaymentLanguage, String)] = [
            (.german, "de"),
            (.english, "en"),
            (.spanish, "es"),
            (.french, "fr"),
            (.japanese, "ja"),
            (.korean, "ko"),
            (.portugueseBrazil, "pt-BR"),
            (.portuguesePortugal, "pt-PT"),
            (.russian, "ru"),
            (.thai, "th"),
            (.chineseSimplified, "zh-Hans"),
            (.chineseTraditional, "zh-Hant")
        ]

        for (language, identifier) in identifiers {
            XCTAssertEqual(language.rawValue, identifier)
        }
        XCTAssertEqual(Set(AWXPaymentLanguage.allCases.map(\.rawValue)), Set(identifiers.map(\.1)))
    }

    func testPaymentSheetLocalizationTablesHaveConsistentKeysAndFormats() throws {
        let bundle = Bundle.paymentSheet
        let english = try localizationTable(in: bundle, localization: "en")

        for localization in bundle.localizations {
            let table = try localizationTable(in: bundle, localization: localization)
            XCTAssertEqual(Set(table.keys), Set(english.keys), "Localization keys differ for \(localization)")
            for key in english.keys {
                XCTAssertEqual(
                    table[key]?.components(separatedBy: "%@").count,
                    english[key]?.components(separatedBy: "%@").count,
                    "Format placeholders differ for \(key) in \(localization)"
                )
            }
        }
    }

    func testSDKModulesShipMatchingLocalizationIdentifiers() {
        let expected = Set(AWXPaymentLanguage.allCases.map(\.rawValue))

        XCTAssertEqual(Set(Bundle.payment.localizations), expected)
        XCTAssertEqual(Set(Bundle.paymentSheet.localizations), expected)
    }

    private func localizationTable(in bundle: Bundle, localization: String) throws -> [String: String] {
        let localizedBundle = try XCTUnwrap(
            bundle.path(forResource: localization, ofType: "lproj").flatMap(Bundle.init(path:))
        )
        let path = try XCTUnwrap(localizedBundle.path(forResource: "Localizable", ofType: "strings"))
        return try XCTUnwrap(NSDictionary(contentsOfFile: path) as? [String: String])
    }
}
