//
//  AirwallexCheckoutMode+Extensions.swift
//  Examples
//
//  Created by Weiping Li on 2025/1/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

extension AirwallexCheckoutMode {
    var localizedDescription: String {
        switch self {
        case .oneOffMode:
            return NSLocalizedString("One-off payment", comment: "SDK demo checkout mode")
        case .recurringMode:
            return NSLocalizedString("Recurring", comment: "SDK demo checkout mode")
        case .recurringWithIntentMode:
            return NSLocalizedString("Recurring with intent", comment: "SDK demo checkout mode")
        }
    }
    
    static var allCases: [AirwallexCheckoutMode] {
        [ .oneOffMode, .recurringMode, .recurringWithIntentMode ]
    }
}
