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
    static let environmentOptionView = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForEnvironment]
    static let optionViewForLayout = app.otherElements[AccessibilityIdentifiers.SettingsScreen.optionButtonForLayout]
    static let customerIDTextField = app.textFields[AccessibilityIdentifiers.SettingsScreen.textFieldForCustomerID]
    static let customerIDActionButton = app.buttons[AccessibilityIdentifiers.SettingsScreen.actionButtonForCustomerID]
    static let toggleFor3DS = app.switches[AccessibilityIdentifiers.SettingsScreen.toggleFor3DS]
    static let alert = app.alerts.firstMatch
    static let activityIndicator = app.activityIndicators.firstMatch
    
    static func validate() {
        XCTAssertTrue(titleLabel.exists)
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(backButton.exists)
    }
    
    static func ensureEnvironment(_ env: Environment) {
        XCTAssertTrue(environmentOptionView.exists)
        guard !environmentOptionView.staticTexts[env.rawValue].exists else {
            // no need to update payment type
            return
        }
        
        environmentOptionView.tap()
        XCTAssertTrue(app.sheets.buttons[env.rawValue].exists)
        app.sheets.buttons[env.rawValue].tap()
        XCTAssertTrue(environmentOptionView.staticTexts[env.rawValue].exists)
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
                customerIDTextField.tap()
                customerIDTextField.typeText(customerID)
            } else {
                customerIDActionButton.tap()
                activityIndicator.waitForNonExistence(timeout: .networkRequestTimeout)
                customerIDTextField.tap()
                customerIDTextField.typeText(customerID)
            }
            app.keyboards.buttons["done"].tap()
        }
    }
    
    static func ensureForce3DS(_ force3DS: Bool) {
        XCTAssertTrue(toggleFor3DS.exists)
        if toggleFor3DS.isSelected != force3DS {
            toggleFor3DS.tap()
        }
        XCTAssertEqual(toggleFor3DS.isSelected, force3DS)
    }
    
    static func ensureLayoutMode(useTabLayout: Bool) {
        XCTAssertTrue(optionViewForLayout.exists)
        let layoutName = useTabLayout ? "tab" : "accordion"
        guard !optionViewForLayout.staticTexts[layoutName].exists else {
            // no need to update payment type
            return
        }
        
        optionViewForLayout.tap()
        XCTAssertTrue(app.sheets.buttons[layoutName].exists)
        app.sheets.buttons[layoutName].tap()
        XCTAssertTrue(optionViewForLayout.staticTexts[layoutName].waitForExistence(timeout: .animationTimeout))
    }
    
    static func close() {
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        XCTAssertTrue(titleLabel.waitForNonExistence(timeout: .animationTimeout))
    }
    
    static func save() {
        if app.keyboards.firstMatch.exists {
            app.keyboards.buttons["done"].tap()
            app.keyboards.firstMatch.waitForNonExistence(timeout: .animationTimeout)
        }
        saveButton.tap()
        XCTAssertTrue(alert.waitForExistence(timeout: .animationTimeout))
        alert.buttons["Close"].tap()
        XCTAssertTrue(titleLabel.waitForNonExistence(timeout: .animationTimeout))
    }
}
