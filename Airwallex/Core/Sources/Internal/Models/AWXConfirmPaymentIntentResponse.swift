//
//  AWXConfirmPaymentIntentResponse.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

/// `AWXConfirmPaymentIntentResponse` includes the result of payment flow.
@objcMembers
@objc
public class AWXConfirmPaymentIntentResponse: AWXResponse, Codable {
    /**
     Currency.
     */
    public let currency: String?

    /**
     Payment amount.
     */
    public private(set) var amount: Double?
    public var objcAmount: NSNumber? {
        return amount as? NSNumber
    }

    /**
     Payment status.
     */
    public let status: String?

    /**
     Next action.
     */
    public let nextAction: AWXConfirmPaymentNextAction?

    /**
     The latest payment attempt object.
     */
    public let latestPaymentAttempt: AWXPaymentAttempt?

    enum CodingKeys: String, CodingKey {
        case currency
        case amount
        case status
        case nextAction = "next_action"
        case latestPaymentAttempt = "latest_payment_attempt"
    }

    public init(currency: String?, amount: NSNumber?, status: String?, nextAction: AWXConfirmPaymentNextAction?, latestPaymentAttempt: AWXPaymentAttempt?) {
        self.currency = currency
        self.amount = amount?.doubleValue
        self.status = status
        self.nextAction = nextAction
        self.latestPaymentAttempt = latestPaymentAttempt
    }

    public static func decodeFromJSON(_ dic: [String: Any]) -> AWXConfirmPaymentIntentResponse {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXConfirmPaymentIntentResponse.self, from: jsonData)

            return result
        } catch {
            print(error.localizedDescription)
            return AWXConfirmPaymentIntentResponse(currency: nil, amount: nil, status: nil, nextAction: nil, latestPaymentAttempt: nil)
        }
    }

    override public class func parse(_ data: Data) -> AWXResponse {
        return AWXConfirmPaymentIntentResponse.from(data) ?? AWXResponse()
    }

    override public static func parseError(_ data: Data) -> AWXAPIErrorResponse? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                as? [String: Any]
            {
                let message = json["message"] as? String ?? ""
                let code = json["code"] as? String ?? ""
                return AWXAPIErrorResponse(message: message, code: code)
            }
        } catch {
            return nil
        }
        return nil
    }

    public func setAmount(_ amount: NSNumber?) {
        if let amount = amount?.doubleValue {
            self.amount = amount
        } else {
            self.amount = nil
        }
    }
}
