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
    static let environmentOptionView = app.otherElements[AccessibilityIdentifiers.environmentOptionButton]
    
    static func validate() {
        XCTAssertTrue(titleLabel.exists)
        XCTAssertTrue(saveButton.exists)
        XCTAssertTrue(backButton.exists)
    }
    
    static func ensureEnvironment(_ env: Environment) {
        XCTAssertTrue(environmentOptionView.exists)
        guard !environmentOptionView.staticTexts[env.rawValue].exists else {
            // no need to update payment type
            backButton.tap()
            titleLabel.waitForNonExistence(timeout: 5)
            return
        }
        
        environmentOptionView.tap()
        XCTAssertTrue(app.sheets.buttons[env.rawValue].exists)
        app.sheets.buttons[env.rawValue].tap()
        XCTAssertTrue(environmentOptionView.staticTexts[env.rawValue].exists)
        
        // save settings
        saveButton.tap()
        
        // relaunch app after environment change
        app.alerts.buttons["Exit"].tap()
        app.launch()
        
        // the relaunched app don't have customed environment variables
        HomeScreen.buttonForUIIntegration.tap()
        UIIntegrationDemoScreen.validate()
    }
}
