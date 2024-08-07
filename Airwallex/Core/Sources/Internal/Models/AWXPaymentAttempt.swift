//
//  AWXPaymentAttempt.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXPaymentAttempt` includes the information of payment attempt.
@objcMembers
@objc
public class AWXPaymentAttempt: NSObject, Codable {
    /**
     Attempt id.
     */
    public let Id: String?

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
    public let paymentMethod: AWXPaymentMethod?

    /**
     The status of payment attempt
     */
    public let status: String?

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
    public let authenticationData: AWXAuthenticationData?

    enum CodingKeys: String, CodingKey {
        case Id = "id"
        case amount
        case paymentMethod = "payment_method"
        case status
        case capturedAmount = "captured_amount"
        case refundedAmount = "refunded_amount"
        case authenticationData = "authentication_data"
    }

    init(Id: String?, amount: Double? = nil, paymentMethod: AWXPaymentMethod?, status: String?, capturedAmount: Double? = nil, refundedAmount: Double? = nil, authenticationData: AWXAuthenticationData?) {
        self.Id = Id
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.status = status
        self.capturedAmount = capturedAmount
        self.refundedAmount = refundedAmount
        self.authenticationData = authenticationData
    }

    public func setAmount(_ amount: NSNumber?) {
        if let amount = amount?.doubleValue {
            self.amount = amount
        } else {
            self.amount = nil
        }
    }

    public func setCapturedAmount(_ amount: NSNumber?) {
        if let amount = amount?.doubleValue {
            capturedAmount = amount
        } else {
            capturedAmount = nil
        }
    }

    public func setRefundedAmount(_ amount: NSNumber?) {
        if let amount = amount?.doubleValue {
            refundedAmount = amount
        } else {
            refundedAmount = nil
        }
    }
}
