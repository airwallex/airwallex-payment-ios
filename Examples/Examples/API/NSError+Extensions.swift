//
//  NSError+Extensions.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/6.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

extension NSError {
    static func airwallexError(localizedMessage: String) -> NSError {
        .init(domain: "com.airwallex.paymentacceptance", code: -1, userInfo: [NSLocalizedDescriptionKey: localizedMessage])
    }
}
