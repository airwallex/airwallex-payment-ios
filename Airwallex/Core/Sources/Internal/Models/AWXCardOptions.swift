//
//  AWXCardOptions.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/// `AWXCardOptions` includes the options of card.
@objcMembers
@objc
public class AWXCardOptions: NSObject, Codable {
    /**
     Should capture automatically when confirm. Default to false. The payment intent will be captured automatically if it is true, and authorized only if it is false.
     */
    public var autoCapture: Bool = false

    /**
     ThreeDs object.
     */
    public var threeDs: AWXThreeDs?

    enum CodingKeys: String, CodingKey {
        case autoCapture = "auto_capture"
        case threeDs = "three_ds"
    }
}
