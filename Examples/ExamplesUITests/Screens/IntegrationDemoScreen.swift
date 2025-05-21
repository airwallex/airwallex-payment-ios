//
//  IntegrationDemoScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum UIIntegrationDemoScreen {
    static let app = XCUIApplication()
    static let title = app.staticTexts["Integrate with Airwallex UI"]
    static let buttonForDefaultPaymentList: XCUIElement = app.buttons["Launch default payments list"]
    static let settingsButton = app.buttons["gear"]
    static let backButton = app.buttons["Back"]
    static let paymentOptionView = app.otherElements[AccessibilityIdentifiers.paymentTypeOptionButton]
    
    static let alert = app.alerts.firstMatch
    
    static func validate() {
        XCTAssert(title.exists)
        XCTAssertTrue(buttonForDefaultPaymentList.exists)
        XCTAssertTrue(settingsButton.exists)
        XCTAssertTrue(backButton.exists)
        XCTAssertTrue(paymentOptionView.exists)
    }
    
    static func launchDefaultPaymentList() {
        XCTAssert(buttonForDefaultPaymentList.exists)
        buttonForDefaultPaymentList.tap()
        title.waitForNonExistence(timeout: 5)
    }
    
    static func ensureCheckoutMode(_ mode: CheckoutMode) {
        XCTAssertTrue(paymentOptionView.exists)
        guard !paymentOptionView.staticTexts[mode.localizedDescription].exists else {
            // no need to update payment type
            return
        }
        
        paymentOptionView.tap()
        XCTAssertTrue(app.sheets.buttons[mode.localizedDescription].exists)
        app.sheets.buttons[mode.localizedDescription].tap()
        XCTAssertTrue(paymentOptionView.staticTexts[mode.localizedDescription].exists)
    }
    
    static func verifyPaymentStatusAlert(title: String?, message: String?) {
        XCTAssert(alert.exists)
        
        if let title {
            XCTAssert(alert.staticTexts[title].exists)
        }
        if let message {
            XCTAssert(alert.staticTexts[message].exists)
        }
        
        alert.buttons["OK"].tap()
        alert.waitForNonExistence(timeout: 5)
    }
}
