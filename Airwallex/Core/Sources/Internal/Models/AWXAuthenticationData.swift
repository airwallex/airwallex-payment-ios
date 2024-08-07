//
//  AWXAuthenticationData.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXAuthenticationData` includes the parameters for 3ds authentication.
@objcMembers
@objc
public class AWXAuthenticationData: NSObject, Codable {
    public let fraudData: AWXAuthenticationDataFraudData?
    public let dsData: AWXAuthenticationDataDsData?

    enum CodingKeys: String, CodingKey {
        case fraudData = "fraud_data"
        case dsData = "ds_data"
    }

    init(fraudData: AWXAuthenticationDataFraudData?, dsData: AWXAuthenticationDataDsData?) {
        self.fraudData = fraudData
        self.dsData = dsData
    }
}

@objc public extension AWXAuthenticationData {
    func isThreeDSVersion2() -> Bool {
        return dsData?.version?.hasPrefix("2.") == true
    }
}

@objcMembers
@objc(AWXAuthenticationDataFraudDataSwift)
public class AWXAuthenticationDataFraudData: NSObject, Codable {
    public let action: String?
    public let score: String?

    init(action: String?, score: String?) {
        self.action = action
        self.score = score
    }
}

@objcMembers
@objc(AWXAuthenticationDataDsDataSwift)
public class AWXAuthenticationDataDsData: NSObject, Codable {
    public let version: String?

    init(version: String?) {
        self.version = version
    }
}
