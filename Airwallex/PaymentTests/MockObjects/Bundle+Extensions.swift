//
//  Bundle+Extensions.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Core

fileprivate class BundleProvider {
    static let bundle = Bundle(for: BundleProvider.self)
}

extension Bundle {
    static func decode<T: AWXJSONDecodable>(file: String, withExtension: String? = "json") -> T? {
        guard let file = BundleProvider.bundle.url(forResource: file, withExtension: withExtension),
              let data = try? Data(contentsOf: file),
              let object = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable : Any],
              let model = T.decode(fromJSON: object) else {
            return nil
        }
        return model as? T
    }
}
