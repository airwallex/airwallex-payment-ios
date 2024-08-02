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
    static func errorForAirwallexSDK(with code: Int, localizedDescription: String) -> NSError {
        return NSError(domain: AWXSDKErrorDomain, code: code, userInfo: [
            NSLocalizedDescriptionKey: localizedDescription,
        ])
    }
}
