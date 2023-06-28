//
//  AirwallexSDKMode+Extensions.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 23/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

extension AirwallexSDKMode {
    var title: String {
        switch self {
        case .demoMode:
            return NSLocalizedString("Demo", comment: "")
        case .stagingMode:
            return NSLocalizedString("Staging", comment: "")
        case .productionMode:
            return NSLocalizedString("Production", comment: "")
        @unknown default:
            return AirwallexSDKMode.demoMode.title
        }
    }
}

// MARK: - String to non-codable type conversions
// This junk should be replaced once the SDK itself is rewritten in Swift and we're able to
// use Codable types.
extension AirwallexSDKMode {
    var stringValue: String {
        switch self {
        case .demoMode: return "demo"
        case .stagingMode: return "staging"
        case .productionMode: return "production"
        @unknown default: return AirwallexSDKMode.demoMode.stringValue
        }
    }
    
    init?(stringValue: String?) {
        switch stringValue {
        case AirwallexSDKMode.demoMode.stringValue: self = .demoMode
        case AirwallexSDKMode.stagingMode.stringValue: self = .stagingMode
        case AirwallexSDKMode.productionMode.stringValue: self = .productionMode
        default: return nil
        }
    }
}
