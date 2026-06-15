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
    /// Returns `true` when the address satisfies its country's rule end-to-end: the country
    /// code is valid, every field declared by `fmt` is non-empty, dropdown-state values map
    /// to a known option, and the postcode matches the country's `zip` regex (when present).
    /// E.g. HK has no postcode in its rule, GB has no state, AE has only state — so the
    /// legacy "every field non-empty" check would have rejected otherwise-valid prefilled
    /// addresses. See `AddressRuleProvider.isValid(_:)`.
    package var isValid: Bool {
        AddressRuleProvider().isValid(self)
    }

    @available(*, deprecated, renamed: "isValid")
    var isComplete: Bool { isValid }
}
