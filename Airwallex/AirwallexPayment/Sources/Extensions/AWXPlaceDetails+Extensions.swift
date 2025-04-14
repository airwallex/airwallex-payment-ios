//
//  AWXPlaceDetails+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif

public extension AWXPlaceDetails {
    var fullName: String {
        (firstName + " " + lastName).trimmed
    }
}

public extension AWXAddress {
    var isComplete: Bool {
        guard let countryCode, !countryCode.trimmed.isEmpty,
              let postcode, !postcode.trimmed.isEmpty,
              let street, !street.trimmed.isEmpty,
              let city, !city.trimmed.isEmpty,
              let state, !state.trimmed.isEmpty else {
            return false
        }
        return true
    }
}
