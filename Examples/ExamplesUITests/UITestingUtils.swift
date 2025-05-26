//
//  UITestingUtils.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

extension TimeInterval {
    static let animationTimeout: TimeInterval = 1
    static let networkRequestTimeout: TimeInterval = 12
    
    static let shortTimeout: TimeInterval = 1
    static let mediumTimeout: TimeInterval = 6
    static let longTimeout: TimeInterval = 12
    static let longLongTimeout: TimeInterval = 24
}

enum TestCards {
    static let visa = "4111111111111111"
    static let visa3DS = "4012000300000088"
    static let unionPay = "6262000000000000"
}
