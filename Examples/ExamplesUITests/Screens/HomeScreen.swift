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
    static func validate() {
        XCTAssertTrue(buttonForUIIntegration.exists)
        XCTAssertTrue(buttonForAPIIntegration.exists)
    }
    static let app = XCUIApplication()
    static let buttonForUIIntegration: XCUIElement = app.buttons["Integrate with Airwallex UI"]
    static let buttonForAPIIntegration: XCUIElement = app.buttons["Integrate with low-level API"]
    
    static func pushUIIntegrationDemos() {
        XCTAssert(buttonForUIIntegration.exists)
        buttonForUIIntegration.tap()
    }
}
