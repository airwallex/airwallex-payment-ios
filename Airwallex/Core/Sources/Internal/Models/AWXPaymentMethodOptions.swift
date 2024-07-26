//
//  AWXPaymentMethodOptions.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXPaymentMethodOptions` includes the info of payment consent.
 */
@objcMembers
@objc
public class AWXPaymentMethodOptions: NSObject, Codable {
    
    /**
     The options for card.
     */
    public var cardOptions: AWXCardOptions?
    
    public static func decodeFromJSON(_ dic: Dictionary<String, Any>) -> AWXPaymentMethodOptions {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXPaymentMethodOptions.self, from: jsonData)
            
            return result
        } catch {
            return AWXPaymentMethodOptions()
        }
    }
    
    public func encodeToJSON() -> [String: Any] {
        return toDictionary() ?? [String: Any]()
    }
}
    
