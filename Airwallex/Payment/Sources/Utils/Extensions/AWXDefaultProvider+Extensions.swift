//
//  AWXDefaultProvider+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/24.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(ApplePay)
import ApplePay
#elseif canImport(AirwallexApplePay)
import AirwallexApplePay

#endif
#if canImport(Card)
import Card
#elseif canImport(AirwallexCard)
import AirwallexCard
#endif

#if canImport(Core)
import Core
    #elseif canImport(AirwallexCore)
import AirwallexCore
#endif

#if canImport(Redirect)
import Redirect
#elseif canImport(AirwallexRedirect)
import AirwallexRedirect
#endif

import PassKit

private let localizationComment = "provider validation"

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
    
    func validate() throws {
        if let methodType = paymentMethodType {
            guard methodType.name == AWXApplePayKey else {
                let localizedString = NSLocalizedString("Invalid payment method name %@ for apple pay", bundle: .payment, comment: localizationComment)
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
                NSLocalizedString("Apple pay options required", bundle: .payment, comment: localizationComment)
            )
        }
        
        guard !options.merchantIdentifier.isEmpty else {
            throw ValidationError.invalidApplePayOptions(
                NSLocalizedString("Merchant ID required", bundle: .payment, comment: localizationComment)
            )
        }
        
        let networks = Set(AWXApplePaySupportedNetworks())
        for network in options.supportedNetworks {
            if !networks.contains(network) {
                let localizedString = NSLocalizedString("Payment network %@ not supported", comment: localizationComment)
                let message = String(format: localizedString, network.rawValue)
                throw ValidationError.invalidApplePayOptions(message)
            }
        }
        
        if #available(iOS 15.0, *) {
            guard PKPaymentAuthorizationController.canMakePayments() else {
                throw ValidationError.applePayNotSupported(
                    NSLocalizedString("Apple Pay not available on current device.", bundle: .payment, comment: localizationComment)
                )
            }
        } else {
            guard PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: options.supportedNetworks,
                capabilities: options.merchantCapabilities
            ) else {
                throw ValidationError.applePayNotSupported(
                    NSLocalizedString("Apple Pay not available on current device.", bundle: .payment, comment: localizationComment)
                )
            }
        }
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
    
    func validate(card: AWXCard, billing: AWXPlaceDetails?) throws {
        try validateMethodTypeAndSession()
        do {
            // if paymentMethodType is nil, means it's comes from low level API integration
            let cardSchemes = paymentMethodType?.cardSchemes ?? AWXCardScheme.allAvailable
            let validator = AWXCardValidator(cardSchemes)
            try validator.validate(card: card, nameRequired: session.requiredBillingContactFields.contains(.name))
        } catch {
            throw ValidationError.invalidCardInfo(underlyingError: error)
        }
        
        guard !session.requiredBillingContactFields.isEmpty else { return }
        
        guard let billing else {
            throw ValidationError.invalidBillingInfo(
                NSLocalizedString("Billing info required", bundle: .payment, comment: localizationComment)
            )
        }
        if session.requiredBillingContactFields.contains(.name) {
            guard !billing.firstName.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing name required", bundle: .payment, comment: localizationComment)
                )
            }
        }
        if session.requiredBillingContactFields.contains(.address) {
            guard let address = billing.address else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing address required", bundle: .payment, comment: localizationComment)
                )
            }
            guard let countryCode = address.countryCode, countryCode.isvalidCountryCode else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing country required", bundle: .payment, comment: localizationComment)
                )
            }
            guard let state = address.state, !state.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing state required", bundle: .payment, comment: localizationComment)
                )
            }
            guard let city = address.city, !city.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing city required", bundle: .payment, comment: localizationComment)
                )
            }
            guard let street = address.street, !street.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing street required", bundle: .payment, comment: localizationComment)
                )
            }
            guard let postcode = address.postcode, !postcode.isEmpty else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing postcode required", bundle: .payment, comment: localizationComment)
                )
            }
        }
        if session.requiredBillingContactFields.contains(.email) {
            guard let email = billing.email, email.isValidEmail else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing email required", bundle: .payment, comment: localizationComment)
                )
            }
        }
        if session.requiredBillingContactFields.contains(.phone) {
            guard let phoneNumber = billing.phoneNumber, phoneNumber.isValidE164PhoneNumber else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing phone number required", bundle: .payment, comment: localizationComment)
                )
            }
        }
        if session.requiredBillingContactFields.contains(.countryCode) {
            guard let countryCode = billing.address?.countryCode, countryCode.isvalidCountryCode else {
                throw ValidationError.invalidBillingInfo(
                    NSLocalizedString("Billing country required", bundle: .payment, comment: localizationComment)
                )
            }
        }
    }
    
    func validate(consent: AWXPaymentConsent) throws {
        try validateMethodTypeAndSession()
        try validate(consentId: consent.id)
    }
    
    func validate(consentId: String) throws {
        try validateMethodTypeAndSession()
        guard !consentId.isEmpty else {
            throw ValidationError.invalidConsent(
                NSLocalizedString("Consent ID required", bundle: .payment, comment: localizationComment)
            )
        }
    }
    
    private func validateMethodTypeAndSession() throws {
        if let methodType = paymentMethodType {
            guard methodType.name == AWXCardKey else {
                let localizedString = NSLocalizedString("Invalid payment method name %@ for card payment", bundle: .payment, comment: localizationComment)
                let message = String(format: localizedString, methodType.name)
                throw ValidationError.invalidMethodType(message)
            }
        }
        do {
            try session.validate()
        } catch {
            throw ValidationError.invalidSession(underlyingError: error)
        }
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
    
    func validate(name: String) throws {
        if let paymentMethodType {
            guard paymentMethodType.name == name,
                  name != AWXCardKey,
                  name != AWXApplePayKey else {
                let localizedString = NSLocalizedString("Invalid payment method name %@", bundle: .payment, comment: localizationComment)
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
}
