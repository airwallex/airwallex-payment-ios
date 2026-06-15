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
    @available(*, deprecated)
    var isComplete: Bool {
        AddressRuleProvider().isValid(self)
    }
}
