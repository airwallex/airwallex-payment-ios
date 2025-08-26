//
//  AWXPaymentConsent+Extensions.swift
//  Airwallex
//
//  Created by Weiping Li on 25/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif

@_spi(AWX) public extension AWXPaymentConsent {
    
    var isCITConsent: Bool {
        nextTriggeredBy == FormatNextTriggerByType(.customerType)
    }
    
    var isMITConsent: Bool {
        nextTriggeredBy == FormatNextTriggerByType(.merchantType)
    }
}
