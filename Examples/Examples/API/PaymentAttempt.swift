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

    var isTerminal: Bool {
        guard failureDetails == nil else {
            return true
        }
        return status.isTerminal
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

        typealias RawValue = String

        init(rawValue: String) {
            switch rawValue.uppercased() {
            case "RECEIVED":
                self = .received
            case "AUTHENTICATION_REDIRECTED":
                self = .authenticationRedirected
            case "PENDING_AUTHORIZATION":
                self = .pendingAuthorization
            case "AUTHORIZED":
                self = .authorized
            case "CAPTURE_REQUESTED":
                self = .captureRequested
            case "EXPIRED":
                self = .expired
            case "CANCELLED":
                self = .cancelled
            case "FAILED":
                self = .failed
            case "SETTLED":
                self = .settled
            case "PAID":
                self = .paid
            default:
                self = .unknown(rawValue)
            }
        }

        var rawValue: String {
            switch self {
            case .received:
                return "RECEIVED"
            case .authenticationRedirected:
                return "AUTHENTICATION_REDIRECTED"
            case .pendingAuthorization:
                return "PENDING_AUTHORIZATION"
            case .authorized:
                return "AUTHORIZED"
            case .captureRequested:
                return "CAPTURE_REQUESTED"
            case .expired:
                return "EXPIRED"
            case .cancelled:
                return "CANCELLED"
            case .failed:
                return "FAILED"
            case .settled:
                return "SETTLED"
            case .paid:
                return "PAID"
            case .unknown(let value):
                return value
            }
        }

        var isTerminal: Bool {
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
