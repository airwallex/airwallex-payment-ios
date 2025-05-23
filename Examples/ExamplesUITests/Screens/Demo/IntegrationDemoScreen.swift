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
    static let paymentOptionView = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForPaymentType]
    
    static let alert = app.alerts.firstMatch
    
    static func validate() {
        XCTAssert(title.exists)
        XCTAssertTrue(buttonForDefaultPaymentList.exists)
        XCTAssertTrue(settingsButton.exists)
        XCTAssertTrue(paymentOptionView.exists)
    }
    
    static func openDefaultPaymentList() {
        XCTAssert(buttonForDefaultPaymentList.exists)
        buttonForDefaultPaymentList.tap()
        title.waitForNonExistence(timeout: .networkRequestTimeout)
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
    
    enum PaymentStatus {
        case success
        case failure(String?)
        case cancel
    }
    
    static func verifyAlertForPaymentStatus(_ status: PaymentStatus) {
        XCTAssert(alert.exists)
        
        switch status {
        case .success:
            XCTAssert(alert.staticTexts["Payment successful"].exists)
            XCTAssert(alert.staticTexts["Your payment has been charged"].exists)
        case .failure(let message):
            XCTAssert(alert.staticTexts["Payment failed"].exists)
            XCTAssert(alert.staticTexts[message ?? "There was an error while processing your payment. Please try again."].exists)
        case .cancel:
            XCTAssert(alert.staticTexts["Payment cancelled"].exists)
            XCTAssert(alert.staticTexts["Your payment has been cancelled"].exists)
        }
        
        alert.buttons["OK"].tap()
        // retrieve payment intent status
        alert.waitForNonExistence(timeout: .animationTimeout)
    }
    
    static func openSettings() {
        XCTAssert(settingsButton.exists && settingsButton.isEnabled)
        settingsButton.tap()
        XCTAssertTrue(title.waitForNonExistence(timeout: .animationTimeout))
    }
}
