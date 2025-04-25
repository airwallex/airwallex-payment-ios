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
            }
        }
    }
    
    func validate() throws {
        if let session = self as? AWXOneOffSession {
            guard let intent = session.paymentIntent else {
                throw ValidationError.invalidPaymentIntent(
                    NSLocalizedString("Payment intent required", bundle: .payment, comment: localizationComment)
                )
            }
            guard !intent.id.isEmpty else {
                throw ValidationError.invalidPaymentIntent(
                    NSLocalizedString("Intent id required", bundle: .payment, comment: localizationComment)
                )
            }
            guard !intent.clientSecret.isEmpty else {
                throw ValidationError.invalidPaymentIntent(
                    NSLocalizedString("Client secret required", bundle: .payment, comment: localizationComment))
            }
        } else if let session = self as? AWXRecurringWithIntentSession {
            guard let intent = session.paymentIntent else {
                throw ValidationError.invalidPaymentIntent(
                    NSLocalizedString("Payment intent required", bundle: .payment, comment: localizationComment)
                )
            }
            guard !intent.id.isEmpty else {
                throw ValidationError.invalidPaymentIntent(
                    NSLocalizedString("Intent id required", bundle: .payment, comment: localizationComment)
                )
            }
            guard !intent.clientSecret.isEmpty else {
                throw ValidationError.invalidPaymentIntent(
                    NSLocalizedString("Client secret required", bundle: .payment, comment: localizationComment)
                )
            }
            guard let customerId = session.customerId(), !customerId.isEmpty else {
                throw ValidationError.invalidCustomerId(
                    NSLocalizedString("Customer ID required", bundle: .payment, comment: localizationComment)
                )
            }
        } else if let session = self as? AWXRecurringSession {
            guard let customerId = session.customerId(), !customerId.isEmpty else {
                throw ValidationError.invalidCustomerId(
                    NSLocalizedString("Customer ID required", bundle: .payment, comment: localizationComment)
                )
            }
        } else {
            throw ValidationError.invalidSessionType(
                NSLocalizedString("Invalid session type", bundle: .payment, comment: localizationComment)
            )
        }
    }
}
