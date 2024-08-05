//
//  AirwallexConstants.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/8/2.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc public enum AWXBrandType: Int, CaseIterable, Codable {
    case unknown
    case visa
    case amex
    case mastercard
    case discover
    case JCB
    case dinersClub
    case unionPay
}
