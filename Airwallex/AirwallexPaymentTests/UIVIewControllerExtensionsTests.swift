//
//  UIVIewControllerExtensionsTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@_spi(AWX) @testable import AirwallexPayment

class UIVIewControllerExtensionsTests: XCTestCase {

    var viewController: UIViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewController = UIViewController()
        UIApplication.shared.windows.first?.rootViewController = viewController
    }

    override func tearDownWithError() throws {
        viewController = nil
        try super.tearDownWithError()
    }

    func testStartLoading() {
        viewController.startLoading()
        XCTAssertTrue(viewController.isLoading)
        XCTAssertFalse(viewController.view.isUserInteractionEnabled)
    }

    func testStopLoading() {
        viewController.startLoading()
        viewController.stopLoading()
        XCTAssertFalse(viewController.isLoading)
        XCTAssertTrue(viewController.view.isUserInteractionEnabled)
    }
}
