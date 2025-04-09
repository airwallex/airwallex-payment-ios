//
//  AWXPlaceDetails+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/28.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#elseif canImport(AirwallexCore)
import AirwallexCore
#endif

extension AWXPlaceDetails {
    var fullName: String {
        (firstName + " " + lastName).trimmed
    }
}
