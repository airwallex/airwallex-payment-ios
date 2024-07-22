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
@objc(AWXConfirmPaymentNextActionSwift)
public class AWXConfirmPaymentNextAction: NSObject, Codable {
    
    /**
     Next action type.
     */
    private(set) var type: String?
    
    /**
     URL.
     */
    private(set) var url: String?
    
    /**
     Method.
     */
    private(set) var method: String?
    
    /**
     Stage.
     */
    private(set) var stage: String?
    
    /**
     Payload of next action.
     */
    var payload: Dictionary<String, String>? {
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
    
}
