//
//  HomeScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum HomeScreen {
    static let app = XCUIApplication()
    static let buttonForUIIntegration: XCUIElement = app.buttons["Integrate with Airwallex UI"]
    static let buttonForAPIIntegration: XCUIElement = app.buttons["Integrate with low-level API"]
    
    static func waitForExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(buttonForUIIntegration.waitForExistence(timeout: timeout))
        XCTAssertTrue(buttonForAPIIntegration.waitForExistence(timeout: timeout))
    }
    
    static func openUIIntegrationDemos() {
        XCTAssert(buttonForUIIntegration.exists)
        buttonForUIIntegration.robustTap()
    }
}
