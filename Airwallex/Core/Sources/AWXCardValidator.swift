//
//  AWXCardValidator.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/8/5.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objcMembers
@objc
public class AWXCardValidator: NSObject {
    public private(set) var defaultBrand: AWXBrand

    public static let shared = AWXCardValidator()

    override public init() {
        defaultBrand = AWXBrand(name: "", rangeStart: "", rangeEnd: "", length: 16, type: .unknown)
        super.init()
    }

    public var brands: [AWXBrand] {
        [
            // Unknown
            defaultBrand,

            // American Express
            AWXBrand(name: "Amex",
                     rangeStart: "34",
                     rangeEnd: "34",
                     length: 15,
                     type: .amex),
            AWXBrand(name: "Amex",
                     rangeStart: "37",
                     rangeEnd: "37",
                     length: 15,
                     type: .amex),
            AWXBrand(name: "American Express",
                     rangeStart: "34",
                     rangeEnd: "34",
                     length: 15,
                     type: .amex),
            AWXBrand(name: "American Express",
                     rangeStart: "37",
                     rangeEnd: "37",
                     length: 15,
                     type: .amex),

            // Diners Club
            AWXBrand(name: "Diners",
                     rangeStart: "300",
                     rangeEnd: "305",
                     length: 14,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "300",
                     rangeEnd: "305",
                     length: 16,
                     type: .dinersClub),
            AWXBrand(name: "Diner",
                     rangeStart: "300",
                     rangeEnd: "305",
                     length: 19,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "36",
                     rangeEnd: "36",
                     length: 14,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "36",
                     rangeEnd: "36",
                     length: 16,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "36",
                     rangeEnd: "36",
                     length: 19,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "38",
                     rangeEnd: "39",
                     length: 14,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "38",
                     rangeEnd: "39",
                     length: 16,
                     type: .dinersClub),
            AWXBrand(name: "Diners",
                     rangeStart: "38",
                     rangeEnd: "39",
                     length: 19,
                     type: .dinersClub),
            AWXBrand(name: "Diners Club International",
                     rangeStart: "300",
                     rangeEnd: "305",
                     length: 14,
                     type: .dinersClub),

            // Discover
            AWXBrand(name: "Discover",
                     rangeStart: "6011",
                     rangeEnd: "6011",
                     length: 16,
                     type: .discover),
            AWXBrand(name: "Discover",
                     rangeStart: "644",
                     rangeEnd: "65",
                     length: 16,
                     type: .discover),
            AWXBrand(name: "Discover",
                     rangeStart: "6011",
                     rangeEnd: "6011",
                     length: 19,
                     type: .discover),
            AWXBrand(name: "Discover",
                     rangeStart: "644",
                     rangeEnd: "65",
                     length: 19,
                     type: .discover),

            // JCB
            AWXBrand(name: "JCB",
                     rangeStart: "3528",
                     rangeEnd: "3589",
                     length: 16,
                     type: .JCB),

            // Mastercard
            AWXBrand(name: "Mastercard",
                     rangeStart: "50",
                     rangeEnd: "59",
                     length: 16,
                     type: .mastercard),
            AWXBrand(name: "Mastercard",
                     rangeStart: "22",
                     rangeEnd: "27",
                     length: 16,
                     type: .mastercard),
            AWXBrand(name: "Mastercard",
                     rangeStart: "67",
                     rangeEnd: "67",
                     length: 16,
                     type: .mastercard),

            // UnionPay
            AWXBrand(name: "UnionPay",
                     rangeStart: "62",
                     rangeEnd: "62",
                     length: 16,
                     type: .unionPay),
            AWXBrand(name: "UnionPay",
                     rangeStart: "62",
                     rangeEnd: "62",
                     length: 17,
                     type: .unionPay),
            AWXBrand(name: "UnionPay",
                     rangeStart: "62",
                     rangeEnd: "62",
                     length: 18,
                     type: .unionPay),
            AWXBrand(name: "UnionPay",
                     rangeStart: "62",
                     rangeEnd: "62",
                     length: 19,
                     type: .unionPay),
            AWXBrand(name: "Union Pay",
                     rangeStart: "62",
                     rangeEnd: "62",
                     length: 16,
                     type: .unionPay),

            // Visa
            AWXBrand(name: "Visa",
                     rangeStart: "40",
                     rangeEnd: "49",
                     length: 16,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "413600",
                     rangeEnd: "413600",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "444509",
                     rangeEnd: "444509",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "444550",
                     rangeEnd: "444550",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "450603",
                     rangeEnd: "450603",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "450617",
                     rangeEnd: "450617",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "450628",
                     rangeEnd: "450628",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "450636",
                     rangeEnd: "450636",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "450640",
                     rangeEnd: "450640",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "450662",
                     rangeEnd: "450662",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "463100",
                     rangeEnd: "463100",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "476142",
                     rangeEnd: "476142",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "476143",
                     rangeEnd: "476143",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492901",
                     rangeEnd: "492901",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492920",
                     rangeEnd: "492920",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492923",
                     rangeEnd: "492923",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492928",
                     rangeEnd: "492928",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492937",
                     rangeEnd: "492937",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492939",
                     rangeEnd: "492939",
                     length: 13,
                     type: .visa),
            AWXBrand(name: "Visa",
                     rangeStart: "492960",
                     rangeEnd: "492960",
                     length: 13,
                     type: .visa),
        ]
    }

    public func maxLengthForCardNumber(_ cardNumber: String) -> Int {
        let brands = brandsForCardNumber(cardNumber)
        let sortedBrands = brands.sorted { $0.length > $1.length }
        if let brandWithMaxLength = sortedBrands.first {
            return brandWithMaxLength.length
        }
        return defaultBrand.length
    }

    public func brandForCardNumber(_ cardNumber: String) -> AWXBrand? {
        let brandsFilteredByPrefix = brandsForCardNumber(cardNumber)

        let brandWithSameLength = brandsFilteredByPrefix.first { $0.length == cardNumber.count }

        if let matchedBrand = brandWithSameLength {
            return matchedBrand
        }
        return brandsFilteredByPrefix.first
    }

    public func brandForCardName(_ name: String) -> AWXBrand? {
        let filtered = brands.filter { $0.name.compare(name, options: .caseInsensitive) == .orderedSame
        }
        return filtered.first
    }

    public func isValidCardLength(_ cardNumber: String) -> Bool {
        if let brand = brandForCardNumber(cardNumber) {
            return brand.length == cardNumber.count
        }
        return false
    }

    public static func cardNumberFormatForBrand(_ type: AWXBrandType) -> [Int] {
        switch type {
        case .amex:
            return [4, 6, 5]
        case .dinersClub:
            return [4, 6, 9]
        default:
            return [4, 4, 4]
        }
    }

    private func brandsForCardNumber(_ cardNumber: String) -> [AWXBrand] {
        return brands.filter { brand in
            brand.type != .unknown && brand.matchesPrefix(cardNumber)
        }
    }
}
