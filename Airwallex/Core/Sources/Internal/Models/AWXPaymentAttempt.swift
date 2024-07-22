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
@objc(AWXPaymentAttemptSwift)
public class AWXPaymentAttempt: NSObject, Codable {
    
    /**
     Attempt id.
     */
    private(set) var Id: String?
    
    /**
     Payment amount.
     */
    private(set) var amount: Decimal?
    
    /**
     Payment method.
     */
    private(set) var paymentMethod: AWXPaymentMethod?

    /**
     The status of payment attempt
     */
    private(set) var status: String?
    
    /**
     Captured amount.
     */
    private(set) var capturedAmount: Decimal?

    /**
     Refunded amount.
     */
    private(set) var refundedAmount: Decimal?
    
    /**
     3DS authentication data.
     */
    private(set) var authenticationData: AWXAuthenticationData?
    
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
