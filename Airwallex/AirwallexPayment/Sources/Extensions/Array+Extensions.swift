//
//  Array.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/20.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@_spi(AWX) public extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
