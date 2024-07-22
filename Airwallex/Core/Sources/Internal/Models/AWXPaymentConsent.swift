//
//  AWXPaymentConsent.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXPaymentConsent` includes the info of payment consent.
 */
@objcMembers
@objc(AWXPaymentConsentSwift)
public class AWXPaymentConsent: NSObject, Codable {
    
    /**
     Consent ID.
     */
    public var Id: String?
    
    /**
     Request ID.
     */
    public var requestId: String?
    
    /**
     Customer ID.
     */
    public var customerId: String?

    /**
     Consent status.
     */
    public var status: String?

    /**
     Payment method.
     */
    public var paymentMethod: AWXPaymentMethod?

    /**
     Next trigger By type.
     */
    public var nextTriggeredBy: String?

    /**
     Merchant trigger reason
     */
    public var merchantTriggerReason: String?

    /**
     Whether it requires CVC.
     */
    public var requiresCVC: Bool = false

    /**
     Created at date.
     */
    public var createdAt: String?

    /**
     Updated at date.
     */
    public var updatedAt: String?

    /**
     Client secret.
     */
    public var clientSecret: String?

}
