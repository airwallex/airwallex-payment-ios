//
//  ExamplesKeys.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/12.
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
            return NSLocalizedString("One-off payment", comment: "SDK demo checkout mode")
        case .recurring:
            return NSLocalizedString("Recurring", comment: "SDK demo checkout mode")
        case .recurringWithIntent:
            return NSLocalizedString("Recurring with intent", comment: "SDK demo checkout mode")
        }
    }
}

struct ExamplesKeys {
    static let storagePrefix = "airwallexExamples-"
    
    @RawRepresentableStorage("environment", defaultValue: AirwallexSDKMode.demoMode)
    static var environment: AirwallexSDKMode
    
    @RawRepresentableStorage("checkoutMode", defaultValue: CheckoutMode.oneOff)
    static var checkoutMode: CheckoutMode
    
    @RawRepresentableStorage("nextTriggerByType", defaultValue: AirwallexNextTriggerByType.customerType)
    static var nextTriggerByType: AirwallexNextTriggerByType
    
    @Storage("autoCapture", defaultValue: false)
    static var autoCapture: Bool
    
    @OptionalStorage("customerId", byEnvironment: true)
    static var customerId: String?
    
    @OptionalStorage("apiKey")
    static var apiKey: String?
    
    @OptionalStorage("clientId")
    static var clientId: String?
    
    @Storage("amount", defaultValue: "")
    static var amount: String
    
    @Storage("currency", defaultValue: "")
    static var currency: String
    
    @Storage("countryCode", defaultValue: "")
    static var countryCode: String
    
    @Storage("returnUrl", defaultValue: "")
    static var returnUrl: String
        
    static var allSettings: AllSettings {
        get {
            AllSettings(
                environment: ExamplesKeys.environment,
                nextTriggerByType: ExamplesKeys.nextTriggerByType,
                autoCapture: ExamplesKeys.autoCapture,
                customerId: ExamplesKeys.customerId,
                apiKey: ExamplesKeys.apiKey,
                clientId: ExamplesKeys.clientId,
                amount: ExamplesKeys.amount,
                currency: ExamplesKeys.currency,
                countryCode: ExamplesKeys.countryCode,
                returnUrl: ExamplesKeys.returnUrl
            )
        }
        set {
            ExamplesKeys.environment = newValue.environment
            ExamplesKeys.nextTriggerByType = newValue.nextTriggerByType
            ExamplesKeys.autoCapture = newValue.autoCapture
            ExamplesKeys.customerId = newValue.customerId
            ExamplesKeys.apiKey = newValue.apiKey
            ExamplesKeys.clientId = newValue.clientId
            ExamplesKeys.amount = newValue.amount
            ExamplesKeys.currency = newValue.currency
            ExamplesKeys.countryCode = newValue.countryCode
            ExamplesKeys.returnUrl = newValue.returnUrl
        }
    }
    
    struct AllSettings: CustomStringConvertible {
        var environment: AirwallexSDKMode
        var nextTriggerByType: AirwallexNextTriggerByType
        var autoCapture: Bool
        var customerId: String?
        
        var apiKey: String?
        var clientId: String?
        var amount: String
        var currency: String
        var countryCode: String
        var returnUrl: String
        
        var description: String {
                """
                🌍 AllSettings:
                ├── Environment: \(environment.displayName)
                ├── Next Trigger Type: \(nextTriggerByType.displayName)
                ├── Auto Capture: \(autoCapture)
                ├── Customer ID: \(customerId ?? "N/A")
                ├── API Key: \(apiKey ?? "N/A")
                ├── Client ID: \(clientId ?? "N/A")
                ├── Amount: \(amount) \(currency)
                ├── Country Code: \(countryCode)
                ├── Return URL: \(returnUrl)
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
        guard let url = Bundle.main.url(forResource: "Keys", withExtension: "json", subdirectory: "Keys"),
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
