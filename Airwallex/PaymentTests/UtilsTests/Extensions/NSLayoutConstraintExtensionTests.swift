//
//  NSLayoutConstraintExtensionTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class NSLayoutConstraintExtensionTests: XCTestCase {

    func testPriority() {
        let constraint = NSLayoutConstraint().priority(.required - 10)
        XCTAssertEqual(constraint.priority, .required - 10, "The priority should be set correctly.")
    }
}
