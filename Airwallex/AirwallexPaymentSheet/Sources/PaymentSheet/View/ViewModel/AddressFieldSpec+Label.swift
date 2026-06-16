//
//  AddressFieldSpec+Label.swift
//  Airwallex
//
//  Copyright © 2026 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

extension AddressFieldSpec {
    /// Localized placeholder for this field, derived from `kind` and `nameType`.
    ///
    /// The extension lives in AirwallexPaymentSheet (not on the type's home module) because
    /// the strings table it reads from is `Bundle.paymentSheet` — `AirwallexPayment` is kept
    /// free of UI strings by design.
    var localizedLabel: String {
        let key: String
        switch kind {
        case .street:
            key = "Street"
        case .state:
            switch nameType?.lowercased() {
            case "province": key = "Province"
            case "prefecture": key = "Prefecture"
            case "do_si": key = "Do Si"
            case "county": key = "County"
            case "parish": key = "Parish"
            case "department": key = "Department"
            case "district": key = "District"
            case "emirate": key = "Emirate"
            case "oblast": key = "Oblast"
            case "area": key = "Area"
            case "island": key = "Island"
            default: key = "State"
            }
        case .city:
            switch nameType?.lowercased() {
            case "post_town": key = "Town"
            case "district": key = "District"
            case "suburb": key = "Suburb"
            default: key = "City"
            }
        case .postcode:
            switch nameType?.lowercased() {
            case "zip": key = "ZIP code"
            case "pin": key = "Pin"
            case "eircode": key = "Eircode"
            default: key = "Postal code"
            }
        }
        return NSLocalizedString(key, bundle: .paymentSheet, comment: "billing address field placeholder")
    }
}
