//
//  AWXSession+Extensions.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#elseif canImport(AirwallexCore)
import AirwallexCore
#endif

extension AWXSession {
    enum ValidationError: LocalizedError, CustomNSError {
        case invalidPaymentIntent(String)
        case invalidCustomerId(String)
        case invalidSessionType(String)
        
        //  CustomNSError
        static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        var errorUserInfo: [String : Any] {
            [ NSLocalizedDescriptionKey: errorDescription ]
        }
        
        //  LocalizedError
        var errorDescription: String {
            switch self {
            case .invalidPaymentIntent(let message):
                return "Invalid payment intent: \(message)"
            case .invalidCustomerId(let message):
                return "Invalid customer ID: \(message)"
            case .invalidSessionType(let message):
                return "Invalid session type: \(message)"
            }
        }
    }
    
    func validate() throws {
        if let session = self as? AWXOneOffSession {
            guard let intent = session.paymentIntent else {
                throw ValidationError.invalidPaymentIntent("payment intent required")
            }
            guard !intent.id.isEmpty else {
                throw ValidationError.invalidPaymentIntent("payment intent id required")
            }
            guard !intent.clientSecret.isEmpty else {
                throw ValidationError.invalidPaymentIntent("client secret required for intent: \(intent.id)")
            }
        } else if let session = self as? AWXRecurringWithIntentSession {
            guard let intent = session.paymentIntent else {
                throw ValidationError.invalidPaymentIntent("payment intent required")
            }
            guard !intent.id.isEmpty else {
                throw ValidationError.invalidPaymentIntent("payment intent id required")
            }
            guard !intent.clientSecret.isEmpty else {
                throw ValidationError.invalidPaymentIntent("client secret required for intent: \(intent.id)")
            }
            guard let customerId = session.customerId(), !customerId.isEmpty else {
                throw ValidationError.invalidCustomerId("customer ID required")
            }
        } else if let session = self as? AWXRecurringSession {
            guard let customerId = session.customerId(), !customerId.isEmpty else {
                throw ValidationError.invalidCustomerId("customer ID required")
            }
        } else {
            throw ValidationError.invalidSessionType("session should be one of AWXOneOffSession/AWXRecurringSession/AWXRecurringWithIntentSession")
        }
    }
}
