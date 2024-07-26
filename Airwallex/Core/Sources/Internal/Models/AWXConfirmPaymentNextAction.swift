//
//  AWXConfirmPaymentNextAction.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXConfirmPaymentNextAction` includes the parameters for next action.
 */
@objcMembers
@objc
public class AWXConfirmPaymentNextAction: NSObject, Codable {
    
    /**
     Next action type.
     */
    public private(set)var type: String?
    
    /**
     URL.
     */
    public private(set)var url: String?
    
    /**
     Method.
     */
    public private(set)var method: String?
    
    /**
     Stage.
     */
    public private(set)var stage: String?
    
    /**
     Payload of next action.
     */
    public var payload: Dictionary<String, String>? {
        data ?? dccData
    }
    
    private var data: Dictionary<String, String>?
    private var dccData: Dictionary<String, String>?
    
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case method
        case stage
        case data
        case dccData = "dcc_data"
    }
    
    public static func decodeFromJSON(_ dic: Dictionary<String, Any>) -> AWXConfirmPaymentNextAction {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let result = try decoder.decode(AWXConfirmPaymentNextAction.self, from: jsonData)
            
            return result
        } catch {
            return AWXConfirmPaymentNextAction()
        }
    }
    
}
