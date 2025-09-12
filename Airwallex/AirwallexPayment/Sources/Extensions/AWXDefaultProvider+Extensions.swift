//
//  AWXDefaultProvider+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import PassKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

extension AWXApplePayProvider {
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
        case invalidSession(underlyingError: Error)
        case invalidApplePayOptions(String)
        case applePayNotSupported(String)
        
        // CustomNSError - for objc
        static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        var errorUserInfo: [String : Any] {
            [NSLocalizedDescriptionKey: errorDescription]
        }
        
        // LocalizedError - for error.localizedDescription
        var errorDescription: String {
            switch self {
            case .invalidMethodType(let message):
                return message
            case .invalidSession(let error):
                return error.localizedDescription
            case .invalidApplePayOptions(let message):
                return message
            case .applePayNotSupported(let message):
                return message
            }
        }
    }
    
    class func validate(paymentMethodType: AWXPaymentMethodType?, session: AWXSession) throws {
        if let methodType = paymentMethodType {
            guard methodType.name == AWXApplePayKey else {
                let localizedString = "Invalid payment method name %@ for apple pay"
                let message = String(format: localizedString, methodType.name)
                throw ValidationError.invalidMethodType(message)
            }
        }
        
        do {
            try session.validate()
        } catch {
            throw ValidationError.invalidSession(underlyingError: error)
        }
        
        guard let options = session.applePayOptions else {
            throw ValidationError.invalidApplePayOptions(
                "Missing Apple Pay options in session."
            )
        }
        
        guard !options.merchantIdentifier.isEmpty else {
            throw ValidationError.invalidApplePayOptions(
                "Apple Pay Merchant ID required"
            )
        }
        
        let networks = Set(AWXApplePaySupportedNetworks())
        for network in options.supportedNetworks {
            if !networks.contains(network) {
                let localizedString = "Payment network %@ not supported"
                let message = String(format: localizedString, network.rawValue)
                throw ValidationError.invalidApplePayOptions(message)
            }
        }
        
        if #available(iOS 15.0, *) {
            guard PKPaymentAuthorizationController.canMakePayments() else {
                throw ValidationError.applePayNotSupported(
                    "Payment not supported via Apple Pay."
                )
            }
        } else {
            guard PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: options.supportedNetworks,
                capabilities: options.merchantCapabilities
            ) else {
                throw ValidationError.applePayNotSupported(
                    "Payment not supported via Apple Pay."
                )
            }
        }
        
        if session.transactionMode() == AWXPaymentTransactionModeRecurring {
            if let session = session as? AWXRecurringSession {
                guard session.nextTriggerByType != .customerType else {
                    throw ValidationError.applePayNotSupported(
                        "CIT not supported by Apple Pay"
                    )
                }
            } else if let session = session as? AWXRecurringWithIntentSession {
                guard session.nextTriggerByType != .customerType else {
                    throw ValidationError.applePayNotSupported(
                        "CIT not supported by Apple Pay"
                    )
                }
            } else if let session = session as? Session {
                guard session.paymentConsentOptions?.nextTriggeredBy != .customerType else {
                    throw ValidationError.applePayNotSupported(
                        "CIT not supported by Apple Pay"
                    )
                }
            }
        }
    }
    
    func validate() throws {
        try AWXApplePayProvider.validate(paymentMethodType: paymentMethodType, session: session)
    }
}

extension AWXCardProvider {
    
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
        case invalidSession(underlyingError: Error)
        case invalidCardSchemes(String)
        case invalidCardInfo(underlyingError: Error)
        case invalidBillingInfo(String)
        case invalidConsent(String)
        
        // CustomNSError - for objc
        static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        var errorUserInfo: [String : Any] {
            [NSLocalizedDescriptionKey: errorDescription]
        }
        
        // LocalizedError - for error.localizedDescription
        var errorDescription: String {
            switch self {
            case .invalidMethodType(let message):
                return message
            case .invalidSession(underlyingError: let error):
                return error.localizedDescription
            case .invalidCardSchemes(let message):
                return message
            case .invalidCardInfo(underlyingError: let error):
                return error.localizedDescription
            case .invalidBillingInfo(let message):
                return message
            case .invalidConsent(let message):
                return message
            }
        }
    }
    
    class func validate(card: AWXCard, billing: AWXPlaceDetails?, paymentMethodType: AWXPaymentMethodType?, session: AWXSession) throws {
        try validateMethodTypeAndSession(paymentMethodType: paymentMethodType, session: session)
        do {
            // if paymentMethodType is nil, means it's comes from low level API integration
            let cardSchemes = paymentMethodType?.cardSchemes ?? AWXCardScheme.allAvailable
            
            try AWXCardValidator.validate(
                card: card,
                nameRequired: session.requiredBillingContactFields.contains(.name),
                supportedSchemes: cardSchemes
            )
        } catch {
            throw ValidationError.invalidCardInfo(underlyingError: error)
        }
        
        guard !session.requiredBillingContactFields.isEmpty else { return }
        
        guard let billing else {
            throw ValidationError.invalidBillingInfo(
                "Billing info required"
            )
        }
        if session.requiredBillingContactFields.contains(.name) {
            guard !billing.firstName.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    "Billing name required"
                )
            }
        }
        if session.requiredBillingContactFields.contains(.address) {
            guard let address = billing.address else {
                throw ValidationError.invalidBillingInfo(
                    "Billing address required"
                )
            }
            guard let countryCode = address.countryCode, countryCode.isValidCountryCode else {
                throw ValidationError.invalidBillingInfo(
                    "Billing country required"
                )
            }
            guard let state = address.state, !state.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    "Billing state required"
                )
            }
            guard let city = address.city, !city.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    "Billing city required"
                )
            }
            guard let street = address.street, !street.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    "Billing street required"
                )
            }
            guard let postcode = address.postcode, !postcode.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    "Billing postcode required"
                )
            }
        }
        if session.requiredBillingContactFields.contains(.email) {
            guard let email = billing.email, email.isValidEmail else {
                throw ValidationError.invalidBillingInfo(
                    "Billing email required"
                )
            }
        }
        if session.requiredBillingContactFields.contains(.phone) {
            guard let phoneNumber = billing.phoneNumber, phoneNumber.isValidE164PhoneNumber else {
                throw ValidationError.invalidBillingInfo(
                    "Billing phone number required"
                )
            }
        }
        if session.requiredBillingContactFields.contains(.countryCode) {
            guard let countryCode = billing.address?.countryCode, countryCode.isValidCountryCode else {
                throw ValidationError.invalidBillingInfo(
                    "Billing country required"
                )
            }
        }
    }
    
    func validate(card: AWXCard, billing: AWXPlaceDetails?) throws {
        try AWXCardProvider.validate(card: card, billing: billing, paymentMethodType: paymentMethodType, session: session)
    }
    
    class func validate(consent: AWXPaymentConsent, paymentMethodType: AWXPaymentMethodType?, session: AWXSession) throws {
        try validateMethodTypeAndSession(paymentMethodType: paymentMethodType, session: session)
        guard !consent.id.isEmpty else {
            throw ValidationError.invalidConsent(
                "Consent ID required"
            )
        }
        if let session = Session(session) {
            if session.paymentConsentOptions != nil {
                guard consent.paymentMethod?.id != nil else {
                    throw ValidationError.invalidConsent("method id required for recurring transactoin with consent")
                }
            }
        }
    }
    
    func validate(consent: AWXPaymentConsent) throws {
        try AWXCardProvider.validate(consent: consent, paymentMethodType: paymentMethodType, session: session)
    }
    
    class func validate(consentId: String, paymentMethodType: AWXPaymentMethodType?, session: AWXSession) throws {
        try validateMethodTypeAndSession(paymentMethodType: paymentMethodType, session: session)
        guard session.transactionMode() == AWXPaymentTransactionModeOneOff else {
            throw ValidationError.invalidSession(
                underlyingError:"transaction mode should be one-off for consent payment with consent Id".asError()
            )
        }
        guard !consentId.isEmpty else {
            throw ValidationError.invalidConsent(
                "Consent ID required"
            )
        }
    }
    
    func validate(consentId: String) throws {
        try AWXCardProvider.validate(consentId: consentId, paymentMethodType: paymentMethodType, session: session)
    }
    
    class func validateMethodTypeAndSession(paymentMethodType: AWXPaymentMethodType?, session: AWXSession) throws {
        if let methodType = paymentMethodType {
            guard methodType.name == AWXCardKey else {
                let localizedString = "Invalid payment method name %@ for card payment"
                let message = String(format: localizedString, methodType.name)
                throw ValidationError.invalidMethodType(message)
            }
            guard !methodType.cardSchemes.isEmpty else {
                throw ValidationError.invalidCardSchemes(
                    "No valid card schemes for payment"
                )
            }
            
            let allAvailable = Set(AWXCardBrand.allAvailable.map { $0.rawValue })
            for name in methodType.cardSchemes.map({ $0.name }) {
                guard allAvailable.contains(name) else {
                    let localizedString = "Card scheme %@ not support for payment"
                    let message = String(format: localizedString, name)
                    throw ValidationError.invalidCardSchemes(message)
                }
            }
        }
        do {
            try session.validate()
        } catch {
            throw ValidationError.invalidSession(underlyingError: error)
        }
    }
    
    private func validateMethodTypeAndSession() throws {
        try AWXCardProvider.validateMethodTypeAndSession(paymentMethodType: paymentMethodType, session: session)
    }
}

extension AWXRedirectActionProvider {
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
        case invalidSession(underlyingError: Error)
        
        // CustomNSError - for objc
        static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        var errorUserInfo: [String : Any] {
            [NSLocalizedDescriptionKey: errorDescription]
        }
        
        // LocalizedError - for error.localizedDescription
        var errorDescription: String {
            switch self {
            case .invalidMethodType(let message):
                return message
            case .invalidSession(underlyingError: let error):
                return error.localizedDescription
            }
        }
    }
    
    class func validate(name: String, paymentMethodType: AWXPaymentMethodType?, session: AWXSession) throws {
        if let paymentMethodType {
            guard paymentMethodType.name == name,
                  name != AWXCardKey,
                  name != AWXApplePayKey,
                  paymentMethodType.hasSchema else {
                let localizedString = "Invalid payment method name %@"
                let message = String(format: localizedString, name)
                throw ValidationError.invalidMethodType(message)
            }
        }
        do {
            try session.validate()
        } catch {
            throw ValidationError.invalidSession(underlyingError: error)
        }
    }
    
    func validate(name: String) throws {
        try AWXRedirectActionProvider.validate(name: name, paymentMethodType: paymentMethodType, session: session)
    }
}
