//
//  AWXCardSchemeExtensionTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
import AirwallexCore

class AWXCardSchemeExtensionTests: XCTestCase {

    func testCardSchemeToBrandTypeConversion() {
        for brand in AWXCardBrand.allAvailable {
            let scheme = AWXCardScheme(name: brand.rawValue)
            XCTAssertEqual(scheme.brandType, brand.brandType)
        }
    }
}
