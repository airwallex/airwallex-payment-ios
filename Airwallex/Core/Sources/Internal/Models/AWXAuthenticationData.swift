//
//  AWXAuthenticationData.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXAuthenticationData` includes the parameters for 3ds authentication.
 */
@objcMembers
@objc
public class AWXAuthenticationData: NSObject, Codable {
    var fraudData: AWXAuthenticationDataFraudData?
    var dsData: AWXAuthenticationDataDsData?
    
    enum CodingKeys: String, CodingKey {
        case fraudData = "fraud_data"
        case dsData = "ds_data"
    }
}

@objc extension AWXAuthenticationData {
    public func isThreeDSVersion2() -> Bool {
        if let version = dsData?.version, version.hasPrefix("2.") {
            return true
        }
        return false
    }
}

@objcMembers
@objc(AWXAuthenticationDataFraudDataSwift)
public class AWXAuthenticationDataFraudData: NSObject, Codable {
    var action: String?
    var score: String?
}

@objcMembers
@objc(AWXAuthenticationDataDsDataSwift)
public class AWXAuthenticationDataDsData: NSObject, Codable {
    var version: String?
}
