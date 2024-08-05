//
//  AWXPaymentAttempt.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXPaymentAttempt` includes the information of payment attempt.
 */
@objcMembers
@objc
public class AWXPaymentAttempt: NSObject, Codable {
    
    /**
     Attempt id.
     */
    public private(set) var Id: String?
    
    /**
     Payment amount.
     */
    public private(set) var amount: Double?
    public var objcAmount: NSNumber? {
        return amount as? NSNumber
    }
    
    /**
     Payment method.
     */
    public private(set) var paymentMethod: AWXPaymentMethod?

    /**
     The status of payment attempt
     */
    public private(set) var status: String?
    
    /**
     Captured amount.
     */
    public private(set) var capturedAmount: Double?
    public var objcCapturedAmount: NSNumber? {
        return capturedAmount as? NSNumber
    }

    /**
     Refunded amount.
     */
    public private(set) var refundedAmount: Double?
    public var objcRefundedAmount: NSNumber? {
        return refundedAmount as? NSNumber
    }
    /**
     3DS authentication data.
     */
    public private(set) var authenticationData: AWXAuthenticationData?
    
    enum CodingKeys: String, CodingKey {
        case Id = "id"
        case amount
        case paymentMethod = "payment_method"
        case status
        case capturedAmount = "captured_amount"
        case refundedAmount = "refunded_amount"
        case authenticationData = "authentication_data"
    }
}
