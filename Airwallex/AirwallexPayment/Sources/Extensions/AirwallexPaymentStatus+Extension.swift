//
//  AirwallexPaymentStatus+Extension.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 26/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

extension AirwallexPaymentStatus: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        case .cancel:
            return "Cancelled"
        case .inProgress:
            return "In Progress"
        @unknown default:
            return "Unknown Status (\(rawValue))"
        }
    }
}
