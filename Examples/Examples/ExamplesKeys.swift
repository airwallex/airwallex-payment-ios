//
//  ExamplesKeys.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/12.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

struct ExamplesKeys {
    static let storagePrefix = "airwallexExamples-"
    
    @RawRepresentableStorage("environment", defaultValue: AirwallexSDKMode.demoMode)
    static var environment: AirwallexSDKMode
    
    @RawRepresentableStorage("checkoutMode", defaultValue: CheckoutMode.oneOff)
    static var checkoutMode: CheckoutMode
    
    @RawRepresentableStorage("nextTriggerByType", defaultValue: AirwallexNextTriggerByType.customerType)
    static var nextTriggerByType: AirwallexNextTriggerByType
    
    @Storage("requiresName", defaultValue: false)
    static var requiresName: Bool
    
    @Storage("requiresEmail", defaultValue: false)
    static var requiresEmail: Bool
    
    @Storage("requiresPhone", defaultValue: false)
    static var requiresPhone: Bool
    
    @Storage("requiresAddress", defaultValue: true)
    static var requiresAddress: Bool
    
    @Storage("requiresCountryCode", defaultValue: false)
    static var requiresCountryCode: Bool
    
    @Storage("force3DS", defaultValue: false)
    static var force3DS: Bool
    
    @Storage("autoCapture", defaultValue: false)
    static var autoCapture: Bool
    
    @OptionalStorage("customerId", byEnvironment: true)
    static var customerId: String?
    
    @OptionalStorage("apiKey", byEnvironment: true)
    static var apiKey: String?
    
    @OptionalStorage("clientId", byEnvironment: true)
    static var clientId: String?
    
    @Storage("amount", defaultValue: "")
    static var amount: String
    
    @Storage("currency", defaultValue: "")
    static var currency: String
    
    @Storage("countryCode", defaultValue: "")
    static var countryCode: String
    
    @Storage("returnUrl", defaultValue: "")
    static var returnUrl: String
    
    @RawRepresentableStorage("paymentLayout", defaultValue: AWXUIContext.PaymentLayout.tab)
    static var paymentLayout: AWXUIContext.PaymentLayout
        
    static var allSettings: AllSettings {
        get {
            AllSettings(
                environment: ExamplesKeys.environment,
                nextTriggerByType: ExamplesKeys.nextTriggerByType,
                requiresName: ExamplesKeys.requiresName,
                requiresEmail: ExamplesKeys.requiresEmail,
                requiresPhone: ExamplesKeys.requiresPhone,
                requiresAddress: ExamplesKeys.requiresAddress,
                requiresCountryCode: ExamplesKeys.requiresCountryCode,
                force3DS: ExamplesKeys.force3DS,
                autoCapture: ExamplesKeys.autoCapture,
                customerId: ExamplesKeys.customerId,
                apiKey: ExamplesKeys.apiKey,
                clientId: ExamplesKeys.clientId,
                amount: ExamplesKeys.amount,
                currency: ExamplesKeys.currency,
                countryCode: ExamplesKeys.countryCode,
                returnUrl: ExamplesKeys.returnUrl,
                paymentLayout: ExamplesKeys.paymentLayout
            )
        }
        set {
            ExamplesKeys.environment = newValue.environment
            Airwallex.setMode(newValue.environment)
            ExamplesKeys.nextTriggerByType = newValue.nextTriggerByType
            ExamplesKeys.requiresName = newValue.requiresName
            ExamplesKeys.requiresEmail = newValue.requiresEmail
            ExamplesKeys.requiresPhone = newValue.requiresPhone
            ExamplesKeys.requiresAddress = newValue.requiresAddress
            ExamplesKeys.requiresCountryCode = newValue.requiresCountryCode
            ExamplesKeys.force3DS = newValue.force3DS
            ExamplesKeys.autoCapture = newValue.autoCapture
            ExamplesKeys.customerId = newValue.customerId?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ExamplesKeys.apiKey = newValue.apiKey
            ExamplesKeys.clientId = newValue.clientId
            ExamplesKeys.amount = newValue.amount
            ExamplesKeys.currency = newValue.currency
            ExamplesKeys.countryCode = newValue.countryCode
            ExamplesKeys.returnUrl = newValue.returnUrl
            ExamplesKeys.paymentLayout = newValue.paymentLayout
        }
    }
    
    class AllSettings: CustomStringConvertible {
        var environment: AirwallexSDKMode
        var nextTriggerByType: AirwallexNextTriggerByType
        var requiresName: Bool
        var requiresEmail: Bool
        var requiresPhone: Bool
        var requiresAddress: Bool
        var requiresCountryCode: Bool
        var force3DS: Bool
        var autoCapture: Bool
        var customerId: String?
        
        var apiKey: String?
        var clientId: String?
        var amount: String
        var currency: String
        var countryCode: String
        var returnUrl: String
        
        var paymentLayout: AWXUIContext.PaymentLayout
        
        init(environment: AirwallexSDKMode,
             nextTriggerByType: AirwallexNextTriggerByType,
             requiresName: Bool,
             requiresEmail: Bool,
             requiresPhone: Bool,
             requiresAddress: Bool,
             requiresCountryCode: Bool,
             force3DS: Bool,
             autoCapture: Bool,
             customerId: String? = nil,
             apiKey: String? = nil,
             clientId: String? = nil,
             amount: String,
             currency: String,
             countryCode: String,
             returnUrl: String,
             paymentLayout: AWXUIContext.PaymentLayout) {
            self.environment = environment
            self.nextTriggerByType = nextTriggerByType
            self.requiresName = requiresName
            self.requiresEmail = requiresEmail
            self.requiresPhone = requiresPhone
            self.requiresAddress = requiresAddress
            self.requiresCountryCode = requiresCountryCode
            self.force3DS = force3DS
            self.autoCapture = autoCapture
            self.customerId = customerId
            self.apiKey = apiKey
            self.clientId = clientId
            self.amount = amount
            self.currency = currency
            self.countryCode = countryCode
            self.returnUrl = returnUrl
            self.paymentLayout = paymentLayout
        }
        
        var description: String {
                """
                🌍 AllSettings:
                ├── Environment: \(environment.displayName)
                ├── Next Trigger Type: \(nextTriggerByType.displayName)
                ├── Requires Name: \(requiresName)
                ├── Requires Email: \(requiresEmail)
                ├── Requires Phone: \(requiresPhone)
                ├── Requires Address: \(requiresAddress)
                ├── Requires Country Code: \(requiresCountryCode)
                ├── Force 3DS: \(force3DS)
                ├── Auto Capture: \(autoCapture)
                ├── Customer ID: \(customerId ?? "N/A")
                ├── API Key: \(apiKey ?? "N/A")
                ├── Client ID: \(clientId ?? "N/A")
                ├── Amount: \(amount) \(currency)
                ├── Country Code: \(countryCode)
                ├── Return URL: \(returnUrl)
                ├── Payment Layout: \(paymentLayout)
                """
        }
    }
    
    private struct DefaultKeys: Decodable {
        let apiKey: String?
        let clientId: String?
        let amount: String
        let currency: String
        let countryCode: String
        let returnUrl: String
    }

    /// call at launch
    static func loadDefaultKeysIfNilOrEmpty() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let url = Bundle.main.url(forResource: "Keys", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let keys = try? decoder.decode(DefaultKeys.self, from: data) else {
            return
        }
#if DEBUG
        if !CommandLine.arguments.contains("-production") {
            if environment == .productionMode {
                // fallback to demo mode
                environment = .demoMode
            }
        }
#endif
        
        if apiKey?.nilIfEmpty == nil { apiKey = keys.apiKey }
        if clientId?.nilIfEmpty == nil { clientId = keys.clientId }
        if amount.isEmpty { amount = keys.amount }
        if currency.isEmpty { currency = keys.currency }
        if countryCode.isEmpty { countryCode = keys.countryCode }
        if returnUrl.isEmpty { returnUrl = keys.returnUrl }
    }
    
    static func reset() {
        let dict = UserDefaults.standard.dictionaryRepresentation()
        for key in dict.keys {
            if key.hasPrefix(ExamplesKeys.storagePrefix) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        loadDefaultKeysIfNilOrEmpty()
    }
    
    static func readValue<T>(_ name: String, environment: AirwallexSDKMode = environment) -> T? {
        let key = ExamplesKeys.storagePrefix + name + "-\(environment.rawValue)"
        return UserDefaults.standard.object(forKey: key) as? T
    }
    
    static func readValue<T: RawRepresentable>(_ name: String, environment: AirwallexSDKMode = environment) -> T? {
        let key = ExamplesKeys.storagePrefix + name + "-\(environment.rawValue)"
        guard let value = UserDefaults.standard.object(forKey: key) as? T.RawValue else { return nil }
        return T(rawValue: value)
    }
}

@propertyWrapper
struct RawRepresentableStorage<T: RawRepresentable> {
    private let name: String
    private let byEnvironment: Bool
    private let defaultValue: T
    private let prefix: String

    init(_ name: String,
         defaultValue: T,
         byEnvironment: Bool = false,
         prefix: String = ExamplesKeys.storagePrefix) {
        self.name = name
        self.byEnvironment = byEnvironment
        self.defaultValue = defaultValue
        self.prefix = prefix
    }

    private var cacheKey: String {
        var key = prefix + name
        if byEnvironment {
            key = key + "-\(Airwallex.mode().rawValue)"
        }
        return key
    }
    
    var wrappedValue: T {
        get {
            guard let value = UserDefaults.standard.object(forKey: cacheKey) as? T.RawValue else {
                return defaultValue
            }
            return T(rawValue: value) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: cacheKey)
        }
    }
}

@propertyWrapper
struct OptionalStorage<T> {
    private let name: String
    private let byEnvironment: Bool
    private let prefix: String

    init(_ name: String,
         byEnvironment: Bool = false,
         prefix: String = ExamplesKeys.storagePrefix) {
        self.name = name
        self.byEnvironment = byEnvironment
        self.prefix = prefix
    }

    private var cacheKey: String {
        var key = prefix + name
        if byEnvironment {
            key = key + "-\(Airwallex.mode().rawValue)"
        }
        return key
    }
    
    var wrappedValue: T? {
        get {
            UserDefaults.standard.object(forKey: cacheKey) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: cacheKey)
        }
    }
}

@propertyWrapper
struct Storage<T> {
    private let name: String
    private let byEnvironment: Bool
    private let defaultValue: T
    private let prefix: String

    init(_ name: String,
         defaultValue: T,
         byEnvironment: Bool = false,
         prefix: String = ExamplesKeys.storagePrefix) {
        self.name = name
        self.byEnvironment = byEnvironment
        self.defaultValue = defaultValue
        self.prefix = prefix
    }

    private var cacheKey: String {
        var key = prefix + name
        if byEnvironment {
            key = key + "-\(Airwallex.mode().rawValue)"
        }
        return key
    }
    
    var wrappedValue: T {
        get {
            (UserDefaults.standard.object(forKey: cacheKey) as? T) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: cacheKey)
        }
    }
}
