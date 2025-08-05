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
    static let activityIndicator = app.webViews.activityIndicators.firstMatch
    
    static func waitForExistence(_ timeout: TimeInterval = .longLongTimeout) {
        XCTAssertTrue(title.waitForExistence(timeout: timeout))
        XCTAssertTrue(textField.waitForExistence(timeout: timeout))
        XCTAssertTrue(activityIndicator.waitForNonExistence(timeout: timeout))
        validate()
    }
    
    static func waitForNonExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(title.waitForNonExistence(timeout: timeout))
    }
    
    static func validate() {
        XCTAssertTrue(title.exists)
        XCTAssertTrue(textField.exists)
        XCTAssertTrue(submitButton.exists)
        XCTAssert(closeButton.exists)
    }
    
    static func handleThreeDS() {
        ThreeDSScreen.waitForExistence()
        textField.tap()
        textField.typeText("1234")
        title.tap()// dismiss keyboard
        XCTAssertTrue(submitButton.isEnabled)
        submitButton.tap()
        waitForNonExistence()
    }
    
    static func cancelThreeDS() {
        XCTAssert(closeButton.exists)
        XCTAssertTrue(closeButton.isEnabled)
        closeButton.tap()
        waitForNonExistence(.animationTimeout)
    }
}
