//
//  AWXThreeDs.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXThreeDs` includes the information of 3ds.
@objcMembers
@objc
public class AWXThreeDs: NSObject, Codable {
    /**
     Three domain request.
     */
    public let paRes: String?

    /**
     Return url.
     */
    public let returnURL: String?

    /**
     Attempt ID.
     */
    public let attemptId: String?

    /**
     Device data collection response.
     */
    public let deviceDataCollectionRes: String?

    /**
     3DS transaction ID.
     */
    public let dsTransactionId: String?

    enum CodingKeys: String, CodingKey {
        case paRes
        case returnURL = "return_url"
        case attemptId
        case deviceDataCollectionRes
        case dsTransactionId
    }

    public init(paRes: String?, returnURL: String?, attemptId: String?, deviceDataCollectionRes: String?, dsTransactionId: String?) {
        self.paRes = paRes
        self.returnURL = returnURL
        self.attemptId = attemptId
        self.deviceDataCollectionRes = deviceDataCollectionRes
        self.dsTransactionId = dsTransactionId
    }
}
