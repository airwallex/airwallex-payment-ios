//
//  AWXCountry.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

final class AWXCountry: NSObject {

    var countryCode = ""
    var countryName = ""

    override init() {
        super.init()
    }

    convenience init?(code: String, language: AWXPaymentLanguage = .english) {
        let locale = Self.locale(for: language)
        guard let countryName = locale.localizedString(forRegionCode: code) else {
            return nil
        }
        self.init()
        self.countryCode = code
        self.countryName = countryName
    }

    static func allCountries(language: AWXPaymentLanguage = .english) -> [AWXCountry] {
        let locale = locale(for: language)
        return Locale.isoRegionCodes.compactMap { code in
            guard let countryName = locale.localizedString(forRegionCode: code) else {
                return nil
            }
            let country = AWXCountry()
            country.countryCode = code
            country.countryName = countryName
            return country
        }.sorted {
            $0.countryName.compare(
                $1.countryName,
                options: [],
                range: nil,
                locale: locale
            ) == .orderedAscending
        }
    }

    private static func locale(for language: AWXPaymentLanguage) -> Locale {
        Locale(identifier: language.rawValue)
    }
}
