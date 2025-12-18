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
    
    struct Status: RawRepresentable, Hashable, Decodable {
        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue.uppercased()
        }

        static let received = Status(rawValue: "RECEIVED")
        static let authenticationRedirected = Status(rawValue: "AUTHENTICATION_REDIRECTED")
        static let pendingAuthorization = Status(rawValue: "PENDING_AUTHORIZATION")
        static let authorized = Status(rawValue: "AUTHORIZED")
        static let captureRequested = Status(rawValue: "CAPTURE_REQUESTED")
        static let expired = Status(rawValue: "EXPIRED")
        static let cancelled = Status(rawValue: "CANCELLED")
        static let failed = Status(rawValue: "FAILED")
        static let settled = Status(rawValue: "SETTLED")
        static let paid = Status(rawValue: "PAID")

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
    }
}
