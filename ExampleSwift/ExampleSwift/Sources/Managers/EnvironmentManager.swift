//
//  EnvironmentManager.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

class EnvironmentManager {

    enum PListKeys: String {
        case environment
        case apiKey = "api_key"
        case clientID = "client_id"
        case returnURL = "return_url"
    }
    
    enum StorageKeys: String {
        case hasPreloadedKeys
        case environment
        case apiKey
        case clientID
        case returnURL
        case checkoutMode
        case nextTriggerBy
        case autocapture
        case requiresCVC
        case amount
        case currency
        case countryCode
        case customerID
    }
    
    // MARK: - Properties

    private static let keysFilename = "Keys"
    private let userDefaults: UserDefaults
    private let bundle: Bundle
    
    // MARK: - Volatile
    
    var authenticationToken: AuthenticationToken?
    
    // MARK: - Initializer

    init(
        userDefaults: UserDefaults = .standard,
        bundle: Bundle = .main
    ) {
        self.userDefaults = userDefaults
        self.bundle = bundle
        
        if !hasPreloadedKeys {
            reset()
            hasPreloadedKeys = true
        }
    }
    
    func clearVolatileProperties() {
        customerID = nil
        authenticationToken = nil
    }
    
    func reset() {
        // keys loaded from config property list
        let storedKeys = bundle.loadPropertyList(name: Self.keysFilename)
        
        self.environment = AirwallexSDKMode(
            stringValue: storedKeys[PListKeys.environment.rawValue]
        ) ?? .demoMode
        self.apiKey = storedKeys[PListKeys.apiKey.rawValue]?.cleaned()
        self.clientID = storedKeys[PListKeys.clientID.rawValue]?.cleaned()
        self.returnURL = storedKeys[PListKeys.returnURL.rawValue]?.cleaned()
        
        // non property list properties
        self.customerID = nil
        self.checkoutMode = .oneOff
        self.nextTriggerBy = .customerType
        self.isAutocaptureEnabled = true
        self.isRequiresCVCEnabled = true
        self.amount = 10
        self.currency = "AUD"
        self.countryCode = "AU"
    }
}

// MARK: - Storage
// This should all be moved to a Swift Codable Property Wrapper
// when the types we're storing conform to Codable
extension EnvironmentManager {
    var hasPreloadedKeys: Bool {
        get {
            userDefaults.bool(forKey: StorageKeys.hasPreloadedKeys.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.hasPreloadedKeys.rawValue)
        }
    }
    
    var environment: AirwallexSDKMode {
        get {
            let value = userDefaults.string(forKey: StorageKeys.environment.rawValue)
            return AirwallexSDKMode(stringValue: value) ?? .demoMode
        }
        set {
            userDefaults.setValue(newValue.stringValue, forKey: StorageKeys.environment.rawValue)
        }
    }
    
    var checkoutMode: AirwallexCheckoutMode {
        get {
            let value = userDefaults.string(forKey: StorageKeys.checkoutMode.rawValue)
            return AirwallexCheckoutMode(stringValue: value) ?? .oneOff
        }
        set {
            userDefaults.setValue(newValue.rawValue, forKey: StorageKeys.checkoutMode.rawValue)
        }
    }
    
    var nextTriggerBy: AirwallexNextTriggerByType {
        get {
            let value = userDefaults.string(forKey: StorageKeys.nextTriggerBy.rawValue)
            return AirwallexNextTriggerByType(stringValue: value) ?? .customerType
        }
        set {
            userDefaults.setValue(newValue.stringValue, forKey: StorageKeys.nextTriggerBy.rawValue)
        }
    }
    
    var apiKey: String? {
        get {
            return userDefaults.string(forKey: StorageKeys.apiKey.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.apiKey.rawValue)
        }
    }
    
    var clientID: String? {
        get {
            return userDefaults.string(forKey: StorageKeys.clientID.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.clientID.rawValue)
        }
    }
    
    var returnURL: String? {
        get {
            return userDefaults.string(forKey: StorageKeys.returnURL.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.returnURL.rawValue)
        }
    }

    var amount: Decimal {
        get {
            return Decimal(
                string: userDefaults.string(forKey: StorageKeys.amount.rawValue) ?? "0"
            ) ?? 0
        }
        set {
            userDefaults.setValue("\(newValue)", forKey: StorageKeys.amount.rawValue)
        }
    }

    var currency: String {
        get {
            return userDefaults.string(forKey: StorageKeys.currency.rawValue) ?? "AUD"
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.currency.rawValue)
        }
    }
    
    var countryCode: String {
        get {
            return userDefaults.string(forKey: StorageKeys.countryCode.rawValue) ?? "AU"
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.countryCode.rawValue)
        }
    }
    
    var isRequiresCVCEnabled: Bool {
        get {
            return userDefaults.bool(forKey: StorageKeys.requiresCVC.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.requiresCVC.rawValue)
        }
    }
    
    var isAutocaptureEnabled: Bool {
        get {
            return userDefaults.bool(forKey: StorageKeys.autocapture.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.autocapture.rawValue)
        }
    }
    
    var customerID: String? {
        get {
            return userDefaults.string(forKey: StorageKeys.customerID.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: StorageKeys.customerID.rawValue)
        }
    }
}
