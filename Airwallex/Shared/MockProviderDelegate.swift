//
//  MockProviderDelegate.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

class MockProviderDelegate: NSObject, AWXProviderDelegate {
    func providerDidStartRequest(_ provider: AWXDefaultProvider) {
        
    }
    
    func providerDidEndRequest(_ provider: AWXDefaultProvider) {
        
    }
    
    func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        
    }
    
    func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        
    }
}
