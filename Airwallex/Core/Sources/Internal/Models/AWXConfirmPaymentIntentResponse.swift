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
@objc
public class AWXConfirmPaymentIntentResponse: AWXResponse, Codable {
    
    /**
     Currency.
     */
    public private(set) var currency: String?
    
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
    public private(set) var status: String?
    
    /**
     Next action.
     */
    public private(set) var nextAction: AWXConfirmPaymentNextAction?
    
    /**
     The latest payment attempt object.
     */
    public private(set) var latestPaymentAttempt: AWXPaymentAttempt?
    
    enum CodingKeys: String, CodingKey {
        case currency
        case amount
        case status
        case nextAction = "next_action"
        case latestPaymentAttempt = "latest_payment_attempt"
    }
    
    public static func decodeFromJSON(_ dic: Dictionary<String, Any>) -> AWXConfirmPaymentIntentResponse {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXConfirmPaymentIntentResponse.self, from: jsonData)
            
            return result
        } catch {
            print(error.localizedDescription)
            return AWXConfirmPaymentIntentResponse()
        }
    }
    
    public override static func parseError(_ data: Data) -> AWXAPIErrorResponse?
    {
        do {
              if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                  let message = json["message"] as? String ?? ""
                  let code = json["code"] as? String ?? ""
                  return AWXAPIErrorResponse(message: message, code: code)
              }
          } catch {
              return nil
          }
          return nil
    }
    
}
