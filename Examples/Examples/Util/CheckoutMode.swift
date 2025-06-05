//
//  CheckoutMode.swift
//  Examples
//
//  Created by Weiping Li on 20/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

enum CheckoutMode: Int, CaseIterable {
    case oneOff
    case recurring
    case recurringWithIntent
    
    var localizedDescription: String {
        switch self {
        case .oneOff:
            return "One-off payment"
        case .recurring:
            return "Recurring"
        case .recurringWithIntent:
            return "Recurring with intent"
        }
    }
}
