//
//  AWXAddress+PaymentSheet.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif

extension AWXAddress {
    var isComplete: Bool {
        guard let countryCode, NSLocale.isoCountryCodes.contains(countryCode),
              let street, !street.trimmed.isEmpty,
              let state, !state.trimmed.isEmpty,
              let city, !city.trimmed.isEmpty,
              let postcode, !postcode.trimmed.isEmpty else {
            return false
        }
        return true
    }
}
