//
//  NSError+Utils.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/8/2.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc
public extension NSError {
    // for OC convenient usage.
    static func errorForAirwallexSDK(with localizedDescription: String) -> NSError {
        return errorForAirwallexSDK(with: -1, localizedDescription: localizedDescription)
    }

    static func errorForAirwallexSDK(with code: Int = -1, localizedDescription: String) -> NSError {
        return NSError(domain: AWXSDKErrorDomain, code: code, userInfo: [
            NSLocalizedDescriptionKey: localizedDescription,
        ])
    }
}
