//
//  Encodable+Extensions.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }
}
