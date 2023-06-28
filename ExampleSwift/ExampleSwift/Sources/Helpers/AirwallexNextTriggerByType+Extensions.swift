//
//  AirwallexNextTriggerByType+Extensions.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 23/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

extension AirwallexNextTriggerByType {
    var title: String {
        switch self {
        case .customerType:
            return NSLocalizedString("Customer", comment: "")
        case .merchantType:
            return NSLocalizedString("Merchant", comment: "")
        @unknown default:
            return AirwallexNextTriggerByType.customerType.title
        }
    }
}

// MARK: - String to non-codable type conversions
// This junk should be replaced once the SDK itself is rewritten in Swift and we're able to
// use Codable types.
extension AirwallexNextTriggerByType {
    var stringValue: String {
        switch self {
        case .customerType: return "customer"
        case .merchantType: return "merchant"
        @unknown default: return AirwallexNextTriggerByType.customerType.stringValue
        }
    }
    
    init?(stringValue: String?) {
        switch stringValue {
        case AirwallexNextTriggerByType.customerType.stringValue: self = .customerType
        case AirwallexNextTriggerByType.merchantType.stringValue: self = .merchantType
        default: return nil
        }
    }
}
