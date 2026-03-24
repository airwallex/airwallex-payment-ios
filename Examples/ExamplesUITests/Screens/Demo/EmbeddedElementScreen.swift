//
//  EmbeddedElementScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 2025/3/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum EmbeddedElementScreen {
    static let app = XCUIApplication()
    static let navigationTitle = app.navigationBars["Demo checkout"]
    static let backButton = navigationTitle.buttons["Back"]
    static let paymentMethodsLabel = app.staticTexts["Payment methods"]
    static let demoStoreLabel = app.staticTexts["Demo store"]
    static let loadingIndicator = app.activityIndicators.firstMatch
    static let applePayMethodCell = app.cells["applepay"]
    static let cardMethodCell = app.cells["card"]
    static let applePayButton = app.cells["applePayButton"].firstMatch
    static let alert = app.alerts.firstMatch

    static func waitForExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: timeout))
        XCTAssertTrue(demoStoreLabel.waitForExistence(timeout: timeout))
        waitForPaymentElementLoaded(timeout)
    }
    
    static func waitForPaymentElementLoaded(_ timeout: TimeInterval = .networkRequestTimeout) {
        // wait for loading indicator to disappear (element creation is async)
        _ = loadingIndicator.waitForNonExistence(timeout: timeout)
        XCTAssertTrue(paymentMethodsLabel.waitForExistence(timeout: timeout))
    }

    static func validate() {
        XCTAssertTrue(navigationTitle.exists)
        XCTAssertTrue(paymentMethodsLabel.exists)
    }

    static func goBack() {
        XCTAssertTrue(backButton.exists)
        backButton.robustTap()
    }

    static func verifyAlertForPaymentStatus(_ status: PaymentStatus) {
        waitForExistence()
        XCTAssert(alert.exists)

        switch status {
        case .success:
            XCTAssert(alert.staticTexts["Payment successful"].exists)
        case .failure:
            XCTAssert(alert.staticTexts["Payment failed"].exists)
        case .cancel:
            XCTAssert(alert.staticTexts["Payment cancelled"].exists)
        }

        alert.buttons["OK"].robustTap()
        // retrieve payment intent status
        alert.waitForNonExistence(timeout: .animationTimeout)
    }
}
