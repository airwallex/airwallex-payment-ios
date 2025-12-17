//
//  PaymentAttempt.swift
//  Examples
//
//  Created by Weiping Li on 11/12/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct PaymentAttempt: Decodable {
    let id: String
    let status: Status
    let failureDetails: FailureDetails?

    struct FailureDetails: Decodable {
        
        struct Details: Decodable {
            let originalResponseCode: String?
            let originalResponseMessage: String?
        }
        
        let code: String
        let message: String
        let details: Details?

        var description: String {
            let code = details?.originalResponseCode ?? code
            let message = details?.originalResponseMessage ?? message
            return "\(code)\n\(message)"
        }
    }
    
    var description: String {
        if let failureDetails {
            return failureDetails.description
        } else {
            return status.description
        }
    }

    var isFinal: Bool {
        guard failureDetails == nil else {
            return true
        }
        return status.isFinal
    }
    
    enum Status: Equatable, RawRepresentable, Decodable {
        case received
        case authenticationRedirected
        case pendingAuthorization
        case authorized
        case captureRequested
        case expired
        case cancelled
        case failed
        case settled
        case paid
        case unknown(String)
        
        private static let mapping: [String: Status] = [
            "RECEIVED": .received,
            "AUTHENTICATION_REDIRECTED": .authenticationRedirected,
            "PENDING_AUTHORIZATION": .pendingAuthorization,
            "AUTHORIZED": .authorized,
            "CAPTURE_REQUESTED": .captureRequested,
            "EXPIRED": .expired,
            "CANCELLED": .cancelled,
            "FAILED": .failed,
            "SETTLED": .settled,
            "PAID": .paid
        ]
        
        init(rawValue: String) {
            self = Self.mapping[rawValue.uppercased()] ?? .unknown(rawValue)
        }
        
        var rawValue: String {
            Self.mapping.first(where: { $0.value == self })?.key ?? {
                if case .unknown(let value) = self {
                    return value
                }
                return ""
            }()
        }

        var isFinal: Bool {
            switch self {
            case .authorized, .captureRequested, .expired, .cancelled, .failed, .settled, .paid:
                return true
            default:
                return false
            }
        }
        
        var description: String {
            switch self {
            case .authorized, .captureRequested, .settled, .paid:
                return "SUCCEED"
            default:
                return rawValue
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self.init(rawValue: rawValue)
        }
    }
}
