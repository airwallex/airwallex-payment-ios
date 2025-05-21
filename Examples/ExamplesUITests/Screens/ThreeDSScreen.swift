//
//  ThreeDSScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum ThreeDSScreen {
    static let app = XCUIApplication()
    static let title = app.webViews.firstMatch.staticTexts["Purchase Authentication"]
    static let textField = app.webViews.firstMatch.textFields.firstMatch
    static let submitButton = app.webViews.firstMatch.buttons["Submit"]
    static let closeButton = app.navigationBars.firstMatch.buttons["close"]
    
    static func validate() {
        XCTAssertTrue(title.exists)
        XCTAssertTrue(textField.exists)
        XCTAssertTrue(submitButton.exists)
        XCTAssert(closeButton.exists)
    }
    
    static func handleThreeDS() {
        textField.tap()
        textField.typeText("1234")
        title.tap()// dismiss keyboard
        XCTAssertTrue(submitButton.isEnabled)
        submitButton.tap()
        title.waitForNonExistence(timeout: 5)
    }
    
    static func cancelThreeDS() {
        XCTAssert(closeButton.exists)
        closeButton.isEnabled
        title.waitForNonExistence(timeout: 5)
    }
}
