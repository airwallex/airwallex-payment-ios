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
    public private(set) var paRes: String?

    /**
     Return url.
     */
    public var returnURL: String?

    /**
     Attempt ID.
     */
    public private(set) var attemptId: String?

    /**
     Device data collection response.
     */
    public private(set) var deviceDataCollectionRes: String?

    /**
     3DS transaction ID.
     */
    public private(set) var dsTransactionId: String?

    enum CodingKeys: String, CodingKey {
        case paRes
        case returnURL = "return_url"
        case attemptId
        case deviceDataCollectionRes
        case dsTransactionId
    }
}
