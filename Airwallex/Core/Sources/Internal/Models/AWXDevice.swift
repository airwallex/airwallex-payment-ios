//
//  AWXDevice.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXDevice` includes the information of 3ds.
 */
@objcMembers
@objc(AWXDeviceSwift)
public class AWXDevice: NSObject, Codable {
    
    public var deviceId: String?
    
}
