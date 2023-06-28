//
//  String+Extensions.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 28/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

extension String {
    func cleaned() -> String? {
        let string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty {
            return nil
        }
        return string
    }
}
