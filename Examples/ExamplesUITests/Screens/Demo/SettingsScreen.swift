//
//  SettingsScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum SettingsScreen {
    
    enum Environment: String {
        case demo = "Demo"
        case staging = "Staging"
        case production = "Production"
    }
    
    static let app = XCUIApplication()
    static let titleLabel = app.staticTexts["Settings"]
    static let saveButton = app.buttons["Save"]
    static let backButton = app.buttons["Back"]
    static let optionViewForEnvironment = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForEnvironment]
    static let optionViewForNextTriggerBy = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForNextTriggerBy]
    static let optionViewForLayout = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForLayout]
    static let customerIDTextField = app.textFields[AccessibilityIdentifiers.SettingsScreen.textFieldForCustomerID]
    static let customerIDActionButton = app.buttons[AccessibilityIdentifiers.SettingsScreen.actionButtonForCustomerID]
    static let toggleFor3DS = app.switches[AccessibilityIdentifiers.SettingsScreen.toggleFor3DS]
    static let toggleForUnifiedSession = app.switches[AccessibilityIdentifiers.SettingsScreen.toggleForUnifiedSession]
    static let toggleForExpressCheckout = app.switches[AccessibilityIdentifiers.SettingsScreen.toggleForExpressCheckout]
    static let alert = app.alerts.firstMatch
    static let activityIndicator = app.activityIndicators.firstMatch
    static let keyboard = app.keyboards.firstMatch
    static let versionlabel = app.staticTexts[AccessibilityIdentifiers.SettingsScreen.versionLabel]
    
    static func validate() {
        XCTAssertTrue(titleLabel.exists)
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(backButton.exists)
    }
    
    static func ensureEnvironment(_ env: Environment) {
        XCTAssertTrue(optionViewForEnvironment.exists)
        guard !optionViewForEnvironment.staticTexts[env.rawValue].exists else {
            // no need to update payment type
            return
        }
        
        optionViewForEnvironment.robustTap()
        XCTAssertTrue(app.buttons[env.rawValue].exists)
        app.buttons[env.rawValue].robustTap()
        XCTAssertTrue(optionViewForEnvironment.staticTexts[env.rawValue].exists)
    }
    
    static func ensureCustomerID(_ customerID: String?) {
        XCTAssertTrue(customerIDTextField.exists)
        XCTAssertTrue(customerIDActionButton.exists)
        let currentText = (customerIDTextField.value as? String) ?? ""
        let customerID = customerID ?? ""
        let placeholder = customerIDTextField.placeholderValue ?? ""
        if currentText == customerID {
            // do nothing
        } else {
            if currentText.isEmpty || currentText == placeholder {
                if !customerID.isEmpty {
                    customerIDTextField.robustTap()
                    customerIDTextField.typeText(customerID)
                }
            } else {
                customerIDActionButton.robustTap()
                activityIndicator.waitForNonExistence(timeout: .networkRequestTimeout)
                customerIDTextField.robustTap()
                customerIDTextField.typeText(customerID)
            }
            dismissKeyboardIfExist()
        }
    }
    
    static func ensureForce3DS(_ force3DS: Bool) {
        XCTAssertTrue(toggleFor3DS.exists)
        var isOn = (toggleFor3DS.value as? String) == "1"
        if isOn != force3DS {
            toggleFor3DS.robustTap()
        }
        isOn = (toggleFor3DS.value as? String) == "1"
        XCTAssertEqual(isOn, force3DS)
    }
    
    static func ensureLayoutMode(useTabLayout: Bool) {
        XCTAssertTrue(optionViewForLayout.exists)
        let layoutName = useTabLayout ? "tab" : "accordion"
        guard !optionViewForLayout.staticTexts[layoutName].exists else {
            // no need to update layout
            return
        }
        
        optionViewForLayout.robustTap()
        XCTAssertTrue(app.buttons[layoutName].exists)
        app.buttons[layoutName].robustTap()
        XCTAssertTrue(optionViewForLayout.staticTexts[layoutName].waitForExistence(timeout: .animationTimeout))
    }
    
    static func ensurePreferUnifiedSession(_ preferUnifiedSession: Bool) {
        XCTAssertTrue(toggleForUnifiedSession.exists)
        var isOn = (toggleForUnifiedSession.value as? String) == "1"
        if isOn != preferUnifiedSession {
            toggleForUnifiedSession.robustTap()
        }
        isOn = (toggleForUnifiedSession.value as? String) == "1"
        XCTAssertEqual(isOn, preferUnifiedSession)
    }
    
    static func ensureExpressCheckout(_ expressCheckout: Bool) {
        XCTAssertTrue(toggleForExpressCheckout.exists)
        var isOn = (toggleForExpressCheckout.value as? String) == "1"
        if isOn != expressCheckout {
            toggleForExpressCheckout.robustTap()
        }
        isOn = (toggleForExpressCheckout.value as? String) == "1"
        XCTAssertEqual(isOn, expressCheckout)
    }
    
    static func ensureNextTriggerByCustomer(_ isTriggerByCustomer: Bool) {
        XCTAssertTrue(optionViewForNextTriggerBy.exists)
        let triggerName = isTriggerByCustomer ? "Customer" : "Merchant"
        guard !optionViewForNextTriggerBy.staticTexts[triggerName].exists else {
            // no need to update trigger
            return
        }
        
        optionViewForNextTriggerBy.robustTap()
        XCTAssertTrue(app.buttons[triggerName].exists)
        app.buttons[triggerName].robustTap()
        XCTAssertTrue(optionViewForNextTriggerBy.staticTexts[triggerName].waitForExistence(timeout: .animationTimeout))
    }
    
    static func close() {
        XCTAssertTrue(backButton.exists)
        backButton.robustTap()
        XCTAssertTrue(titleLabel.waitForNonExistence(timeout: .animationTimeout))
    }
    
    static func save() {
        dismissKeyboardIfExist()
        app.swipeUp(velocity: .fast)
        XCTAssertTrue(saveButton.waitForExistence(timeout: .animationTimeout))
        saveButton.robustTap()
        XCTAssertTrue(alert.waitForExistence(timeout: .animationTimeout))
        alert.buttons["Close"].robustTap()
        XCTAssertTrue(titleLabel.waitForNonExistence(timeout: .animationTimeout))
    }
    
    static func dismissKeyboardIfExist() {
        if app.staticTexts["Speed up your typing by sliding your finger across the letters to compose a word."].exists {
            app.staticTexts["Continue"].robustTap()
        }
        if keyboard.exists {
            keyboard.buttons["done"].robustTap()
            keyboard.waitForNonExistence(timeout: .animationTimeout)
        }
        if keyboard.exists {
            app.swipeUp(velocity: .fast)
            XCTAssertTrue(versionlabel.exists && versionlabel.isHittable)
            versionlabel.robustTap()
        }
        XCTAssertTrue(keyboard.waitForNonExistence(timeout: .mediumTimeout))
    }
}
