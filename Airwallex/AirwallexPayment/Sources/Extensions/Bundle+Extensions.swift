//
//  Bundle+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

fileprivate class BundleProvider {
    static let bundle = Bundle(for: BundleProvider.self)
}

extension Bundle {
#if !SWIFT_PACKAGE
    static var payment: Bundle {
        guard let url = BundleProvider.bundle.url(forResource: "AirwallexPayment", withExtension: "bundle"),
              let bundle = Bundle(url: url) else {
            return BundleProvider.bundle
        }
        return bundle
    }
#endif
}
