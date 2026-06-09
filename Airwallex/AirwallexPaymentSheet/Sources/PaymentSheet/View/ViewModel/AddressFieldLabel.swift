//
//  AddressFieldLabel.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import Foundation

enum AddressFieldLabel {

    static func state(for countryCode: String?) -> String {
        let key: String
        switch countryCode?.uppercased() {
        case "CN":
            key = "Province"
        case "JP":
            key = "Prefecture"
        case "KR":
            key = "Do Si"
        case "IE", "TW":
            key = "County"
        case "BB", "JM":
            key = "Parish"
        case "CO", "HN", "NI":
            key = "Department"
        case "NR":
            key = "District"
        case "AE":
            key = "Emirate"
        case "RU", "UA":
            key = "Oblast"
        case "HK":
            key = "Area"
        case "BS", "CV", "KI", "KN", "KY", "PF", "SC", "TV":
            key = "Island"
        default:
            key = "State"
        }
        return NSLocalizedString(key, bundle: .paymentSheet, comment: "billing state placeholder")
    }

    static func city(for countryCode: String?) -> String {
        let key: String
        switch countryCode?.uppercased() {
        case "GB", "NO", "SE", "SJ":
            key = "Town"
        case "HK", "PE", "TR":
            key = "District"
        case "AU":
            key = "Suburb"
        default:
            key = "City"
        }
        return NSLocalizedString(key, bundle: .paymentSheet, comment: "billing city placeholder")
    }

    static func postcode(for countryCode: String?) -> String {
        let key: String
        switch countryCode?.uppercased() {
        case "US", "GU", "PR":
            key = "ZIP code"
        case "IN":
            key = "Pin"
        case "IE":
            key = "Eircode"
        default:
            key = "Postal code"
        }
        return NSLocalizedString(key, bundle: .paymentSheet, comment: "billing postal code placeholder")
    }
}
