//
//  AWXConfirmPaymentNextAction+Extension.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 21/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

extension AWXConfirmPaymentNextAction {
    
    open override var debugDescription: String {
        return """
        🔄 AWXConfirmPaymentNextAction:
        ├── type: \(type)
        ├── url: \(url ?? "nil")
        ├── fallbackUrl: \(fallbackUrl ?? "nil")
        ├── method: \(method ?? "nil")
        ├── stage: \(stage ?? "nil")
        └── payload: \(payload?.description ?? "nil")
        """
    }
}
