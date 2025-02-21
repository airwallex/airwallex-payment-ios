//
//  AirwallexSDKMode+Extensions.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/13.
//  Copyright © 2025 Airwallex. All rights reserved.
//

extension AirwallexSDKMode {
    var displayName: String {
        switch self {
        case .demoMode:
            return "Demo"
        case .stagingMode:
            return "Staging"
        case .productionMode:
            return "Production"
        }
    }
}

extension AirwallexNextTriggerByType {
    var displayName: String {
        switch self {
        case .customerType:
            return "Customer"
        case .merchantType:
            return "Merchant"
        }
    }
}
