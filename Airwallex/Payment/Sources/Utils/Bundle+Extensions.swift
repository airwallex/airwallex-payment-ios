//
//  Bundle+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//


fileprivate class BundleProvider {
    static let bundle = Bundle(for: BundleProvider.self)
}

extension Bundle {
    static let payment: Bundle = {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        guard let url = BundleProvider.bundle.url(forResource: "AirwallexPayment", withExtension: "bundle"),
              let bundle = Bundle(url: url) else {
            return BundleProvider.bundle
        }
        return bundle
#endif
    }()
}
