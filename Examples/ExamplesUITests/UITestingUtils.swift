//
//  UITestingUtils.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

extension TimeInterval {
    static let animationTimeout: TimeInterval = 2
    static let networkRequestTimeout: TimeInterval = 6
    
    static let shortTimeout: TimeInterval = 1
    static let mediumTimeout: TimeInterval = 5
    static let longTimeout: TimeInterval = 10
    static let longLongTimeout: TimeInterval = 15
}

enum TestCards {
    static let visa = "4111111111111111"
    static let visa3DS = "4012000300000088"
    static let unionPay = "6262000000000000"
}
//
//enum ThreeDSChallengeStyle {
//    case none// no challenge
//    case explicit// UI challenge
//    case implicit// Collect device info
//    case combined// UI chanlenge and collect device info
//}
