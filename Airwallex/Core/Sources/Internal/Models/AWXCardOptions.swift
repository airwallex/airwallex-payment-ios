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
    public let autoCapture: Bool

    /**
     ThreeDs object.
     */
    public let threeDs: AWXThreeDs?

    enum CodingKeys: String, CodingKey {
        case autoCapture = "auto_capture"
        case threeDs = "three_ds"
    }

    public init(autoCapture: Bool, threeDs: AWXThreeDs?) {
        self.autoCapture = autoCapture
        self.threeDs = threeDs
    }
}
