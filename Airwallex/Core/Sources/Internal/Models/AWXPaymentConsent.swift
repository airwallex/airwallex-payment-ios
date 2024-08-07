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
    public let id: String?

    /**
     Request ID.
     */
    public let requestId: String?

    /**
     Customer ID.
     */
    public let customerId: String?

    /**
     Consent status.
     */
    public let status: String?

    /**
     Payment method.
     */
    public let paymentMethod: AWXPaymentMethod?

    /**
     Next trigger By type.
     */
    public let nextTriggeredBy: String?

    /**
     Merchant trigger reason
     */
    public let merchantTriggerReason: String?

    /**
     Whether it requires CVC.
     */
    public let requiresCVC: Bool = false

    /**
     Created at date.
     */
    public let createdAt: String?

    /**
     Updated at date.
     */
    public let updatedAt: String?

    /**
     Client secret.
     */
    public let clientSecret: String?

    enum CodingKeys: String, CodingKey {
        case id
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

    public init(id: String?, requestId: String?, customerId: String?, status: String?, paymentMethod: AWXPaymentMethod?, nextTriggeredBy: String?, merchantTriggerReason: String?, createdAt: String?, updatedAt: String?, clientSecret: String?) {
        self.id = id
        self.requestId = requestId
        self.customerId = customerId
        self.status = status
        self.paymentMethod = paymentMethod
        self.nextTriggeredBy = nextTriggeredBy
        self.merchantTriggerReason = merchantTriggerReason
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.clientSecret = clientSecret
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXPaymentConsent {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let result = try JSONDecoder().decode(AWXPaymentConsent.self, from: jsonData)

            return result
        } catch {
            return AWXPaymentConsent(id: nil, requestId: nil, customerId: nil, status: nil, paymentMethod: nil, nextTriggeredBy: nil, merchantTriggerReason: nil, createdAt: nil, updatedAt: nil, clientSecret: nil)
        }
    }
}
