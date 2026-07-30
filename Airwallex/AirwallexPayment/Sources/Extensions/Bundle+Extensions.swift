//
//  Bundle+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/16.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

private class BundleProvider {
    static let bundle = Bundle(for: BundleProvider.self)
}

extension Bundle {
    static var payment: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        guard let url = BundleProvider.bundle.url(forResource: "AirwallexPayment", withExtension: "bundle"),
              let bundle = Bundle(url: url) else {
            return BundleProvider.bundle
        }
        return bundle
#endif
    }

    /// Returns the strings-only bundle for the requested payment UI language.
    package func language(_ language: AWXPaymentLanguage) -> Bundle {
        if let path = path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if let path = path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return self
    }
}
