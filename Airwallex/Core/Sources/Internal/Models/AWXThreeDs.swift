//
//  AWXThreeDs.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXThreeDs` includes the information of 3ds.
 */
@objcMembers
@objc(AWXThreeDsSwift)
public class AWXThreeDs: NSObject, Codable {
    
    /**
     Three domain request.
     */
    public var paRes: String?
    
    /**
     Return url.
     */
    public var returnURL: String?
    
    /**
     Attempt ID.
     */
    public var attemptId: String?
    
    /**
     Device data collection response.
     */
    public var deviceDataCollectionRes: String?
    
    /**
     3DS transaction ID.
     */
    public var dsTransactionId: String?
    
}
