//
//  Bundle+Extensions.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 23/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

extension Bundle {
    func loadPropertyList(name: String) -> [String: String] {
        guard let url = self.url(forResource: name, withExtension: "plist") else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            let plist = try PropertyListSerialization.propertyList(
                from: data,
                options: .mutableContainers,
                format: nil
            ) as? [String: String]
            
            return plist ?? [:]
        } catch {
            return [:]
        }
    }
}
