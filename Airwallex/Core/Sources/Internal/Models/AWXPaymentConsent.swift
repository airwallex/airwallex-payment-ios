//
//  AWXPaymentConsent.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXPaymentConsent` includes the info of payment consent.
@objcMembers
@objc
public class AWXPaymentConsent: NSObject, Codable {
    /**
     Consent ID.
     */
    public var Id: String?

    /**
     Request ID.
     */
    public private(set) var requestId: String?

    /**
     Customer ID.
     */
    public private(set) var customerId: String?

    /**
     Consent status.
     */
    public private(set) var status: String?

    /**
     Payment method.
     */
    public private(set) var paymentMethod: AWXPaymentMethod?

    /**
     Next trigger By type.
     */
    public private(set) var nextTriggeredBy: String?

    /**
     Merchant trigger reason
     */
    public private(set) var merchantTriggerReason: String?

    /**
     Whether it requires CVC.
     */
    public private(set) var requiresCVC: Bool = false

    /**
     Created at date.
     */
    public private(set) var createdAt: String?

    /**
     Updated at date.
     */
    public private(set) var updatedAt: String?

    /**
     Client secret.
     */
    public private(set) var clientSecret: String?

    enum CodingKeys: String, CodingKey {
        case Id = "id"
        case requestId = "request_id"
        case customerId = "customer_id"
        case status
        case paymentMethod = "payment_method"
        case nextTriggeredBy = "next_triggered_by"
        case merchantTriggerReason = "merchant_trigger_reason"
        case requiresCVC = "requires_cvc"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case clientSecret = "client_secret"
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentConsent {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXPaymentConsent.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentConsent()
        }
    }
}
