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
        case invalidMethodType
        case applePayOptionNotFound
        case paymentNetworkNotSupported
        case merchantIdRequired
        case applePayNotSupported
        
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
            case .invalidMethodType:
                return NSLocalizedString("Invalid method type", bundle: .payment, comment: "")
            case .applePayOptionNotFound:
                return NSLocalizedString("Invalid apple pay options", bundle: .payment, comment: "")
            case .paymentNetworkNotSupported:
                return NSLocalizedString("Invalid payment network", bundle: .payment, comment: "")
            case .applePayNotSupported:
                return NSLocalizedString("Device can not make payments", bundle: .payment, comment: "")
            case .merchantIdRequired:
                return NSLocalizedString("Invalid merchant Identifier", bundle: .payment, comment: "")
            }
        }
    }
    
    static func validate(session: AWXSession, methodType: AWXPaymentMethodType?) throws {
        if let methodType {
            guard methodType.name == AWXApplePayKey else {
                throw ValidationError.invalidMethodType
            }
        }
        
        guard let options = session.applePayOptions else {
            throw ValidationError.applePayOptionNotFound
        }
        
        guard !options.merchantIdentifier.isEmpty else {
            throw ValidationError.merchantIdRequired
        }
        
        guard Set(options.supportedNetworks).isSubset(of: AWXApplePaySupportedNetworks()) else {
            throw ValidationError.paymentNetworkNotSupported
        }
        
        if #available(iOS 15.0, *) {
            guard PKPaymentAuthorizationController.canMakePayments() else {
                throw ValidationError.applePayNotSupported
            }
        } else {
            guard PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: options.supportedNetworks,
                capabilities: options.merchantCapabilities
            ) else {
                throw ValidationError.applePayNotSupported
            }
        }
    }
}

extension AWXCardProvider {
    
    enum ValidationError: CustomNSError, LocalizedError {
        case invalidMethodType(String)
        case invalidCardSchemes(String)
        case invalidCardInfo(String)
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
            case .invalidCardSchemes(let message):
                return message
            case .invalidCardInfo(let message):
                return message
            case .invalidBillingInfo(let message):
                return message
            case .invalidConsent(let message):
                return message
            }
        }
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         card: AWXCard,
                         billing: AWXPlaceDetails?) throws {
        if let methodType {
            guard methodType.name == AWXCardKey else {
                throw ValidationError.invalidMethodType("invalid method type name should be \(AWXCardKey)")
            }
            guard !methodType.cardSchemes.isEmpty else {
                throw ValidationError.invalidCardSchemes("card schemes should not be empty")
            }
            guard Set(methodType.cardSchemes.map { $0.name }).isSubset(of: AWXCardBrand.all.map { $0.rawValue }) else {
                throw ValidationError.invalidCardSchemes("card scheme not supported")
            }
        }
        let cardSchemes = methodType?.cardSchemes ?? AWXCardScheme.allAvailable
        let validator = AWXCardValidator(cardSchemes)
        do {
            try validator.validate(card: card, nameRequired: session.requiredBillingContactFields.contains(.name))
        } catch {
            throw ValidationError.invalidCardInfo(error.localizedDescription)
        }
        
        guard !session.requiredBillingContactFields.isEmpty else { return }
        
        guard let billing else {
            throw ValidationError.invalidBillingInfo("Invalid billing info")
        }
        if session.requiredBillingContactFields.contains(.name) {
            guard !billing.firstName.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid name")
            }
        }
        if session.requiredBillingContactFields.contains(.address) {
            guard let address = billing.address else {
                throw ValidationError.invalidBillingInfo("Invalid address")
            }
            guard let countryCode = address.countryCode, countryCode.isvalidCountryCode else {
                throw ValidationError.invalidBillingInfo("Invalid country code")
            }
            guard let state = address.state, !state.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid state")
            }
            guard let city = address.city, !city.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid city")
            }
            guard let street = address.street, !street.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid street")
            }
            guard let postcode = address.postcode, !postcode.isEmpty else {
                throw ValidationError.invalidBillingInfo("Invalid postcode")
            }
        }
        if session.requiredBillingContactFields.contains(.email) {
            guard let email = billing.email, email.isValidEmail else {
                throw ValidationError.invalidBillingInfo("Invalid email")
            }
        }
        if session.requiredBillingContactFields.contains(.phone) {
            guard let phoneNumber = billing.phoneNumber, phoneNumber.isValidE164PhoneNumber else {
                throw ValidationError.invalidBillingInfo("Invalid phone number")
            }
        }
        if session.requiredBillingContactFields.contains(.countryCode) {
            guard let countryCode = billing.address?.countryCode, countryCode.isvalidCountryCode else {
                throw ValidationError.invalidBillingInfo("Invalid country code")
            }
        }
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         consent: AWXPaymentConsent) throws {
        if let methodType {
            guard methodType.name == AWXCardKey else {
                throw ValidationError.invalidMethodType("Invalid method type: \(methodType.name)")
            }
        }
        try validate(session: session, methodType: methodType, consentId: consent.id)
    }
    
    static func validate(session: AWXSession,
                         methodType: AWXPaymentMethodType?,
                         consentId: String) throws {
        if let methodType {
            guard methodType.name == AWXCardKey else {
                throw ValidationError.invalidMethodType("Invalid method type: \(methodType.name)")
            }
        }
        guard !consentId.isEmpty, consentId.hasPrefix("cst_") else {
            throw ValidationError.invalidConsent("invalid consentId \(consentId)")
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
            throw ValidationError.invalidMethodType("method type not matched")
        }
        guard name != AWXCardKey else {
            throw ValidationError.invalidMethodType("use startCardPayment or startConsentPayment instead")
        }
        guard name != AWXApplePayKey else {
            throw ValidationError.invalidMethodType("use startApplePay() instead")
        }
    }
}
