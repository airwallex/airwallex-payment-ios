//
//  SettingsViewModel.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 14/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

class SettingsViewModel {
    
    private let environmentManager: EnvironmentManager
    
    var environment: AirwallexSDKMode {
        get { environmentManager.environment }
        set {
            environmentManager.clearVolatileProperties()
            environmentManager.environment = newValue
            Airwallex.setMode(newValue)
        }
    }
    
    var checkoutMode: AirwallexCheckoutMode {
        get { environmentManager.checkoutMode }
        set { environmentManager.checkoutMode = newValue }
    }
    
    var nextTriggerBy: AirwallexNextTriggerByType {
        get { environmentManager.nextTriggerBy }
        set { environmentManager.nextTriggerBy = newValue }
    }
    
    var apiKey: String? {
        get { environmentManager.apiKey }
        set {
            environmentManager.clearVolatileProperties()
            environmentManager.apiKey = newValue
        }
    }
    
    var clientID: String? {
        get { environmentManager.clientID }
        set {
            environmentManager.clearVolatileProperties()
            environmentManager.clientID = newValue
        }
    }
    
    var returnURL: String? {
        get { environmentManager.returnURL }
        set { environmentManager.returnURL = newValue }
    }
    
    var amount: Decimal {
        get { environmentManager.amount }
        set { environmentManager.amount = newValue }
    }
    
    var currency: String {
        get { environmentManager.currency }
        set { environmentManager.currency = newValue }
    }
    
    var countryCode: String {
        get { environmentManager.countryCode }
        set { environmentManager.countryCode = newValue }
    }
    
    var isRequiresCVCEnabled: Bool {
        get { environmentManager.isRequiresCVCEnabled }
        set { environmentManager.isRequiresCVCEnabled = newValue }
    }
    
    var isAutocaptureEnabled: Bool {
        get { environmentManager.isAutocaptureEnabled }
        set { environmentManager.isAutocaptureEnabled = newValue }
    }
    
    init(environmentManager: EnvironmentManager = Dependencies.shared.environmentManager) {
        self.environmentManager = environmentManager
    }
    
    func reset() {
        environmentManager.reset()
    }
}
