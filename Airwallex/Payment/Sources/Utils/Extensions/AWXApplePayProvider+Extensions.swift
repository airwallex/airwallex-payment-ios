//
//  AWXApplePayProvider+Extensions.swift
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

import PassKit

extension AWXApplePayProvider {
    
    enum ValidationError: LocalizedError {
        case InvalidMethodType
        case ApplePayOptionNotFound
        case PaymentNetworkNotSupported
        case NotSupported
        
        var errorDescription: String? {
            switch self {
            case .InvalidMethodType:
                return "Invalid method type"
            case .ApplePayOptionNotFound:
                return "session.applePayOptions required"
            case .PaymentNetworkNotSupported:
                return "Currently we only support networks in AWXApplePaySupportedNetworks"
            case .NotSupported:
                return "PKPaymentAuthorizationController.canMakePayments return false, "
            }
        }
    }
    
    static func validate(session: AWXSession, methodType: AWXPaymentMethodType?) throws {
        if let methodType {
            guard methodType.name == AWXApplePayKey else {
                throw ValidationError.InvalidMethodType
            }
        }
        
        guard let options = session.applePayOptions else {
            throw ValidationError.ApplePayOptionNotFound
        }
        
        guard Set(options.supportedNetworks).isSubset(of: AWXApplePaySupportedNetworks()) else {
            throw ValidationError.PaymentNetworkNotSupported
        }
        
        if #available(iOS 15.0, *) {
            guard PKPaymentAuthorizationController.canMakePayments() else {
                throw ValidationError.NotSupported
            }
        } else {
            guard PKPaymentAuthorizationController.canMakePayments(
                usingNetworks: options.supportedNetworks,
                capabilities: options.merchantCapabilities
            ) else {
                throw ValidationError.NotSupported
            }
        }
    }
}

extension AWXCardProvider {
    
    enum ValidationError: LocalizedError {
        case InvalidMethodType(String)
        case InvalidCardSchemes(String)
        case InvalidCardBilling(String)
        
        var errorDescription: String? {
            switch self {
            case .InvalidMethodType(let message):
                return message
            case .InvalidCardSchemes(let message):
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
                throw ValidationError.InvalidMethodType("invalid method type name should be \(AWXCardKey)")
            }
            guard !methodType.cardSchemes.isEmpty else {
                throw ValidationError.InvalidCardSchemes("card schemes should not be empty")
            }
            guard Set(methodType.cardSchemes.map { $0.name }).isSubset(of: AWXCardBrand.all.map { $0.rawValue }) else {
                throw ValidationError.InvalidCardSchemes("card scheme not supported")
            }
        }
        let cardSchemes = methodType?.cardSchemes ?? AWXCardBrand.all.map {
            let scheme = AWXCardScheme()
            scheme.name = $0.rawValue
            return scheme
        }
        let validator = AWXCardValidator(cardSchemes)
        try validator.validate(card: card, nameRequired: session.requiredBillingContactFields.contains(.name))
        
        if let billing {
            if session.requiredBillingContactFields.contains(.name) {
                guard !billing.firstName.isEmpty else {
                    throw ValidationError.InvalidCardBilling("first name not found")
                }
            }
            if session.requiredBillingContactFields.contains(.address) {
                guard let address = billing.address else {
                    throw ValidationError.InvalidCardBilling("address not found")
                }
                guard let countryCode = address.countryCode, countryCode.isValidE164PhoneNumber
            }
        }
    }
}
