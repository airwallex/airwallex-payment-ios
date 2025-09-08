//
//  AWXSession+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif

fileprivate let localizationComment = "session validation"

public extension AWXSession {
    enum ValidationError: LocalizedError, CustomNSError {
        case invalidPaymentIntent(String)
        case invalidCustomerId(String)
        case invalidSessionType(String)
        case invalidData(String)
        
        //  CustomNSError
        public static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        public var errorUserInfo: [String : Any] {
            [ NSLocalizedDescriptionKey: errorDescription ]
        }
        
        //  LocalizedError
        var errorDescription: String {
            switch self {
            case .invalidPaymentIntent(let message):
                return message
            case .invalidCustomerId(let message):
                return message
            case .invalidSessionType(let message):
                return message
            case .invalidData(let message):
                return message
            }
        }
    }
    
    func validate() throws {
        if !(self is AWXOneOffSession || self is AWXRecurringSession || self is AWXRecurringWithIntentSession || self is Session) {
            throw ValidationError.invalidSessionType(
                "Invalid session type: \(type(of: self))"
            )
        }
        
        if let errorMessage = validateData() {
            // utilize this objc implementation to check nil for nonnull properties
            throw ValidationError.invalidData(errorMessage)
        }
        guard NSLocale.isoCountryCodes.contains(countryCode) else {
            throw ValidationError.invalidData(
                "invalid country code: \(String(describing: countryCode))"
            )
        }
        
        guard NSLocale.isoCurrencyCodes.contains(currency()) else {
            throw ValidationError.invalidData(
                "Invalid currency code: \(String(describing: currency())), ISO 4217 currency code required"
            )
        }
        
        if let session = self as? AWXOneOffSession {
            try validate(paymentIntent: session.paymentIntent)
        } else if let session = self as? AWXRecurringWithIntentSession {
            try validate(paymentIntent: session.paymentIntent)
            guard let customerId = session.customerId(), !customerId.isEmpty else {
                throw ValidationError.invalidCustomerId(
                    "Customer ID required"
                )
            }
        } else if let session = self as? AWXRecurringSession {
            guard let customerId = session.customerId(), !customerId.isEmpty else {
                throw ValidationError.invalidCustomerId(
                    "Customer ID required"
                )
            }
        } else if let session = self as? Session {
            try validate(paymentIntent: session.paymentIntent)
            if let recurringOptions = session.recurringOptions {
                guard let customerId = session.customerId(), !customerId.isEmpty else {
                    throw ValidationError.invalidCustomerId(
                        "Customer ID required"
                    )
                }
                try recurringOptions.validate()
            }
        }
    }
    
    private func validate(paymentIntent: AWXPaymentIntent?) throws {
        guard let paymentIntent else {
            throw ValidationError.invalidPaymentIntent(
                "Payment intent required"
            )
        }
        guard !paymentIntent.id.isEmpty else {
            throw ValidationError.invalidPaymentIntent(
                "Intent id required"
            )
        }
        
        guard !paymentIntent.clientSecret.isEmpty else {
            throw ValidationError.invalidPaymentIntent(
                "Client secret required"
            )
        }
    }
}
