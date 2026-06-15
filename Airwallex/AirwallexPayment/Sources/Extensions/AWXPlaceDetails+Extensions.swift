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
    /// True iff every field the country's address rule declares (`fmt`) is non-empty.
    /// E.g. HK has no postcode in its rule, GB has no state, AE has only state — so the
    /// legacy "every field non-empty" check would have rejected otherwise-valid prefilled
    /// addresses. See `AddressRuleProvider.isComplete(_:)`.
    var isComplete: Bool {
        AddressRuleProvider().isValid(self)
    }
}
