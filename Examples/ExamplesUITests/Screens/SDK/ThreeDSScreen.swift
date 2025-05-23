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
    static let closeButton = app.buttons["close"]
    
    static var exists: Bool {
        title.waitForExistence(timeout: .networkRequestTimeout)
    }
    
    static func validate() {
        XCTAssertTrue(title.waitForExistence(timeout: .networkRequestTimeout))
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
        title.waitForNonExistence(timeout: .networkRequestTimeout)
    }
    
    static func cancelThreeDS() {
        XCTAssert(closeButton.exists)
        XCTAssertTrue(closeButton.isEnabled)
        closeButton.tap()
        title.waitForNonExistence(timeout: .animationTimeout)
    }
}
