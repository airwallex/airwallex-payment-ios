//
//  ErrorMessageTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

class ErrorMessageTests: XCTestCase {
    func testErrorMessageInitialization() {
        let errorMessage = ErrorMessage(rawValue: "Test error message")
        XCTAssertEqual(errorMessage.rawValue, "Test error message")
    }

    func testErrorMessageDescription() {
        let errorMessage = ErrorMessage(rawValue: "Test error description")
        XCTAssertEqual(errorMessage.errorDescription, "Test error description")
    }
}
