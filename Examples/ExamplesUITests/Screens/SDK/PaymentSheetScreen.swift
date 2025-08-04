//
//  PaymentSheetScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum PaymentSheetScreen {
    static let app = XCUIApplication()
    static let title = app.cells["list_title"].staticTexts.firstMatch
    static let backButton = app.navigationBars.firstMatch.buttons["Back"]
    static let closeButton = app.navigationBars.firstMatch.buttons["close"]
    static let applePayButton = app.cells["applepay"].firstMatch.buttons.firstMatch
    static let checkoutButton = app.cells["checkoutButton"].buttons.firstMatch
    
    static func validate() {
        XCTAssertTrue(title.exists)
    }
    
    static func cancelPayment() {
        XCTAssertTrue(backButton.exists || closeButton.exists)
        if backButton.exists {
            backButton.tap()
        }
        if closeButton.exists {
            closeButton.tap()
        }
        waitForNonExistence(.animationTimeout)
    }
    
    static func waitForNonExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(title.waitForNonExistence(timeout: timeout))
        XCTAssertTrue(checkoutButton.waitForNonExistence(timeout: timeout))
    }
    
    static func waitForExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(title.waitForExistence(timeout: timeout))
    }
}


