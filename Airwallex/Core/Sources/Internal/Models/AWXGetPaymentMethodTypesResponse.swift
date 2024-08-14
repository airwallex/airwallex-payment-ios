//
//  AWXGetPaymentMethodTypesResponse.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/8/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXGetPaymentMethodTypesResponse` includes the list of payment methods.
 */
@objcMembers
@objc
public class AWXGetPaymentMethodTypesResponse: AWXResponse, Codable {
    /**
     Payment methods.
     */
    public let items: [AWXPaymentMethodType]?
    public var hasMore: Bool = false

    enum CodingKeys: String, CodingKey {
        case items
        case hasMore = "has_more"
    }
}
