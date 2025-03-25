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

extension AWXApplePayProvider { 
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
        case applePayOptionNotFound(String)
        case paymentNetworkNotSupported(String)
        case merchantIdRequired(String)
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
                return "Invalid method type: \(message)"
            case .applePayOptionNotFound(let message):
                return "Invalid apple pay options: \(message)"
            case .paymentNetworkNotSupported(let message):
                return "Invalid payment network: \(message)"
            case .applePayNotSupported(let message):
                return "Device can not make payments: \(message)"
            case .merchantIdRequired(let message):
                return "Invalid merchant Identifier: \(message)"
            }
        }
    }
    
    static func validate(session: AWXSession, methodType: AWXPaymentMethodType?) throws {
        if let methodType {
            guard methodType.name == AWXApplePayKey else {
                throw ValidationError.invalidMethodType("Expected methodType.name to be \(AWXApplePayKey), but found \(methodType.name)")
            }
        }
        
        guard let options = session.applePayOptions else {
            throw ValidationError.applePayOptionNotFound("session.applePayOptions is required")
        }
        
        guard !options.merchantIdentifier.isEmpty else {
            throw ValidationError.merchantIdRequired("invalid merchant ID")
        }
        
        guard Set(options.supportedNetworks).isSubset(of: AWXApplePaySupportedNetworks()) else {
            throw ValidationError.paymentNetworkNotSupported("only payment networks in AWXApplePaySupportedNetworks are supported")
        }
        
        if #available(iOS 15.0, *) {
            guard PKPaymentAuthorizationController.canMakePayments() else {
                throw ValidationError.applePayNotSupported("canMakePayments return false")
            }
        } else {
            guard PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: options.supportedNetworks,
                capabilities: options.merchantCapabilities
            ) else {
                throw ValidationError.applePayNotSupported("canMakePayments return false")
            }
        }
    }
}

extension AWXCardProvider {
    
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
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
                return "Invalid method type: \(message)"
            case .invalidCardSchemes(let message):
                return "Invalid card schemes: \(message)"
            case .invalidCardInfo(underlyingError: let error):
                return "Invalid card info: \(error.localizedDescription)"
            case .invalidBillingInfo(let message):
                return "Invalid billing info: \(message)"
            case .invalidConsent(let message):
                return "Invalid consent: \(message)"
            }
        }
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         card: AWXCard,
                         billing: AWXPlaceDetails?) throws {
        if let methodType {
            guard methodType.name == AWXCardKey else {
                throw ValidationError.invalidMethodType("Invalid method type")
            }
            guard !methodType.cardSchemes.isEmpty,
                  Set(methodType.cardSchemes.map { $0.name }).isSubset(of: AWXCardBrand.all.map { $0.rawValue }) else {
                throw ValidationError.invalidCardSchemes("Invalid card schemes")
            }
        }
        let cardSchemes = methodType?.cardSchemes ?? AWXCardScheme.allAvailable
        let validator = AWXCardValidator(cardSchemes)
        do {
            try validator.validate(card: card, nameRequired: session.requiredBillingContactFields.contains(.name))
        } catch {
            throw ValidationError.invalidCardInfo(underlyingError: error)
        }
        
        guard !session.requiredBillingContactFields.isEmpty else { return }
        
        guard let billing else {
            throw ValidationError.invalidBillingInfo("Invalid billing: N/A")
        }
        if session.requiredBillingContactFields.contains(.name) {
            guard !billing.firstName.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid name: \(billing.firstName + "" + billing.lastName)")
            }
        }
        if session.requiredBillingContactFields.contains(.address) {
            guard let address = billing.address else {
                throw ValidationError.invalidBillingInfo("Invalid address: N/A")
            }
            guard let countryCode = address.countryCode, countryCode.isvalidCountryCode else {
                throw ValidationError.invalidBillingInfo("Invalid country code: \(address.countryCode ?? "N/A")")
            }
            guard let state = address.state, !state.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid state: \(address.state ?? "N/A")")
            }
            guard let city = address.city, !city.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid city: \(address.city ?? "N/A")")
            }
            guard let street = address.street, !street.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid street: \(address.street ?? "N/A")")
            }
            guard let postcode = address.postcode, !postcode.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid postcode: \(address.postcode ?? "N/A")")
            }
        }
        if session.requiredBillingContactFields.contains(.email) {
            guard let email = billing.email, email.isValidEmail else {
                throw ValidationError.invalidBillingInfo("Invalid email: \(billing.email ?? "N/A")")
            }
        }
        if session.requiredBillingContactFields.contains(.phone) {
            guard let phoneNumber = billing.phoneNumber, phoneNumber.isValidE164PhoneNumber else {
                throw ValidationError.invalidBillingInfo("Invalid phone number: \(billing.phoneNumber ?? "N/A")")
            }
        }
        if session.requiredBillingContactFields.contains(.countryCode) {
            guard let countryCode = billing.address?.countryCode, countryCode.isvalidCountryCode else {
                throw ValidationError.invalidBillingInfo("Invalid country code: \(billing.address?.countryCode ?? "N/A")")
            }
        }
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         consent: AWXPaymentConsent) throws {
        if let methodType {
            guard methodType.name == AWXCardKey else {
                throw ValidationError.invalidMethodType("Invalid method type: \(methodType.name), \(AWXCardKey) expected")
            }
        }
        try validate(session: session, methodType: methodType, consentId: consent.id)
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         consentId: String) throws {
        if let methodType {
            guard methodType.name == AWXCardKey else {
                throw ValidationError.invalidMethodType("Invalid method type: \(methodType.name), \(AWXCardKey) expected")
            }
        }
        guard !consentId.isEmpty, consentId.hasPrefix("cst_") else {
            throw ValidationError.invalidConsent("invalid consentId: \(consentId)")
        }
    }
}

extension AWXRedirectActionProvider {
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
        
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
            }
        }
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         name: String) throws {
        guard (methodType == nil || methodType?.name == name) else {
            throw ValidationError.invalidMethodType("method name: \(name) not equal to methodType.name: \(methodType?.name ?? "")")
        }
        guard name != AWXCardKey else {
            throw ValidationError.invalidMethodType("should never use AWXRedirectActionProvider for card payment")
        }
        guard name != AWXApplePayKey else {
            throw ValidationError.invalidMethodType("should never use AWXRedirectActionProvider for apple pay")
        }
    }
}
