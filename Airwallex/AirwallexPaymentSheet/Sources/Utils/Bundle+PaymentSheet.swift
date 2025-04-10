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
    static var paymentSheet: Bundle {
        guard let url = BundleProvider.bundle.url(forResource: "AirwallexPaymentSheet", withExtension: "bundle"),
              let bundle = Bundle(url: url) else {
            return BundleProvider.bundle
        }
        return bundle
    }
#endif
}
