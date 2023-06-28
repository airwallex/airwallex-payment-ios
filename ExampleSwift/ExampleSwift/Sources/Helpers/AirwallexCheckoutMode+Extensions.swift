//
//  AirwallexCheckoutMode+Extensions.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 23/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

extension AirwallexCheckoutMode {
    var title: String {
        switch self {
        case .oneOff:
            return NSLocalizedString("One-off", comment: "")
        case .recurring:
            return NSLocalizedString("Recurring", comment: "")
        case .recurringWithIntent:
            return NSLocalizedString("Recurring with Intent", comment: "")
        }
    }
}

// MARK: - String to non-codable type conversions
// This junk should be replaced once the SDK itself is rewritten in Swift and we're able to
// use Codable types.
extension AirwallexCheckoutMode {
    init?(stringValue: String?) {
        switch stringValue {
        case AirwallexCheckoutMode.oneOff.rawValue: self = .oneOff
        case AirwallexCheckoutMode.recurring.rawValue: self = .recurring
        case AirwallexCheckoutMode.recurringWithIntent.rawValue: self = .recurringWithIntent
        default: return nil
        }
    }
}
