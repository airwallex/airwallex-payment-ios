//
//  AWXBrand.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/8/5.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXBrand` manages the card scheme brand.
 */
@objcMembers
@objc
public class AWXBrand: NSObject, Codable {
    /**
     The brand name.
     */
    public var name: String

    /**
     The start of  card No.
     */
    public var rangeStart: String

    /**
     The end of  card No.
     */
    public var rangeEnd: String

    /**
     The length of  card No.
     */
    public var length: Int

    /**
     The brand type.
     */
    public var type: AWXBrandType

    init(name: String, rangeStart: String, rangeEnd: String, length: Int, type: AWXBrandType) {
        self.name = name
        self.rangeStart = rangeStart
        self.rangeEnd = rangeEnd
        self.length = length
        self.type = type
    }

    func matchesPrefix(_ number: String) -> Bool {
        var withinLowRange = false
        var withinHighRange = false

        if number.count < rangeStart.count, let numberInt = Int(number), let startInt = Int(rangeStart.prefix(number.count)) {
            withinLowRange = numberInt >= startInt
        } else if let numberPrefixInt = Int(number.prefix(rangeStart.count)), let startInt = Int(rangeStart) {
            withinLowRange = numberPrefixInt >= startInt
        }

        if number.count < rangeEnd.count, let numberInt = Int(number), let endInt = Int(rangeEnd.prefix(number.count)) {
            withinHighRange = numberInt <= endInt
        } else if let numberPrefixInt = Int(number.prefix(rangeEnd.count)), let endInt = Int(rangeEnd) {
            withinHighRange = numberPrefixInt <= endInt
        }

        return withinLowRange && withinHighRange
    }
}
