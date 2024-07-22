//
//  AWXConfirmPaymentIntentResponse.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

/**
 `AWXConfirmPaymentIntentResponse` includes the result of payment flow.
 */
@objcMembers
@objc(AWXConfirmPaymentIntentResponseSwift)
public class AWXConfirmPaymentIntentResponse: NSObject, Codable {
    
    /**
     Currency.
     */
    private(set) var currency: String?
    
    /**
     Payment amount.
     */
    private(set) var amount: Decimal?
    
    /**
     Payment status.
     */
    private(set) var status: String?
    
    /**
     Next action.
     */
    private(set) var nextAction: AWXConfirmPaymentNextAction?
    
    /**
     The latest payment attempt object.
     */
    private(set) var latestPaymentAttempt: AWXPaymentAttempt?
    
    enum CodingKeys: String, CodingKey {
        case currency
        case amount
        case status
        case nextAction = "next_action"
        case latestPaymentAttempt = "latest_payment_attempt"
    }
}
