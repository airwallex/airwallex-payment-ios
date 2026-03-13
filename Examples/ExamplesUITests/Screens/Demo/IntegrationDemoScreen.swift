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
    static let buttonForEmbeddedElement1: XCUIElement = app.buttons["Embedded element"]
    static let buttonForEmbeddedElement2: XCUIElement = app.buttons["Embedded element (inline apple pay)"]
    static let buttonForEmbeddedElement3: XCUIElement = app.buttons["Embedded element (card only)"]
    static let settingsButton = app.buttons["gear"]
    static let backButton = app.buttons["Back"]
    static let paymentOptionView = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForPaymentType]
    
    static let alert = app.alerts.firstMatch
    
    static func waitForNonExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(title.waitForNonExistence(timeout: timeout))
    }
    
    static func waitForExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(title.waitForExistence(timeout: timeout))
        validate()
    }
    
    static func validate() {
        XCTAssert(title.exists)
        XCTAssertTrue(buttonForDefaultPaymentList.exists)
        XCTAssertTrue(settingsButton.exists)
        XCTAssertTrue(paymentOptionView.exists)
    }
    
    static func openDefaultPaymentList() {
        buttonForDefaultPaymentList.robustTap()
        title.waitForNonExistence(timeout: .networkRequestTimeout)
    }
    
    static func openEmbeddedElement(elementStyle: EmbeddedElementStyle) {
        let button: XCUIElement
        switch elementStyle {
        case .paymentSheetDefault:
            button = buttonForEmbeddedElement1
        case .paymentSheetInlineApplePay:
            button = buttonForEmbeddedElement2
        case .addCard:
            button = buttonForEmbeddedElement3
        }
        button.robustTap()
        EmbeddedElementScreen.waitForExistence()
        if elementStyle == .paymentSheetDefault {
            XCTAssertTrue(EmbeddedElementScreen.applePayButton.exists)
        } else if elementStyle == .paymentSheetInlineApplePay {
            // usually card is displayed as default payment method
            XCTAssertFalse(EmbeddedElementScreen.applePayButton.exists)
        }
    }
    
    enum EmbeddedElementStyle {
        /// `.paymentSheet` element with Apple Pay as primary button
        case paymentSheetDefault
        /// `.paymentSheet` element with Apple Pay in method list
        case paymentSheetInlineApplePay
        /// `.addCard` element
        case addCard
    }
    
    static func ensureCheckoutMode(_ mode: CheckoutMode) {
        XCTAssertTrue(paymentOptionView.exists)
        guard !paymentOptionView.staticTexts[mode.localizedDescription].exists else {
            // no need to update payment type
            return
        }
        
        paymentOptionView.robustTap()
        XCTAssertTrue(app.buttons[mode.localizedDescription].waitForExistence(timeout: .animationTimeout))
        app.buttons[mode.localizedDescription].robustTap()
        XCTAssertTrue(paymentOptionView.staticTexts[mode.localizedDescription].exists)
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
    
    static func openSettings() {
        XCTAssert(settingsButton.exists && settingsButton.isEnabled)
        settingsButton.robustTap()
        XCTAssertTrue(title.waitForNonExistence(timeout: .animationTimeout))
    }
}
