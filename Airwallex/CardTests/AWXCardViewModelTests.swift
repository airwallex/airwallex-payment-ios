//
//  AWXCardViewModelTests.swift
//  CardTests
//
//  Created by Tony He (CTR) on 2024/8/2.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

import UIKit
import XCTest

@testable import Card

class AWXCardViewModelTests: XCTestCase {
    func testEnableTaoEndEditing() {
        let session = AWXOneOffSession()
        let cardSchemes = ["visa", "mastercard", "unionpay", "jcb", "diners", "discover"].map {
            let card = AWXCardScheme()
            card.name = $0
            return card
        }
        let viewModel = AWXCardViewModel(session: session, supportedCardSchemes: cardSchemes)

        let brands = viewModel.makeDisplayedCardBrands()
        XCTAssertEqual(brands.count, 6)
        XCTAssertEqual(brands[0], AWXBrandType.visa.rawValue)
        XCTAssertEqual(brands[1], AWXBrandType.mastercard.rawValue)
        XCTAssertEqual(brands[2], AWXBrandType.discover.rawValue)
        XCTAssertEqual(brands[3], AWXBrandType.JCB.rawValue)
        XCTAssertEqual(brands[4], AWXBrandType.dinersClub.rawValue)
        XCTAssertEqual(brands[5], AWXBrandType.unionPay.rawValue)
    }
}
