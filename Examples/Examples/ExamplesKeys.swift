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
    static var environment: AirwallexSDKMode {
        didSet {
            apiKey = nil
            clientId = nil
            loadDefaultKeysIfNilOrEmpty()
        }
    }
    
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
