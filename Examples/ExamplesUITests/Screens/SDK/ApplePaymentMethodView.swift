//
//  ApplePaymentMethodView.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 9/3/26.
//  Copyright © 2026 Airwallex. All rights reserved.
//

import Foundation
import XCTest

// This payment method view primarily only for applepay displayed inline
enum ApplePaymentMethodView {
    static let app = XCUIApplication()
    static let accordionKey = app.cells["accordionKey"].firstMatch
    static let applePayReminder = app.cells["applePayReminder"].firstMatch
    static let applePayButton = app.cells["applePayButton"].firstMatch

    static func validate() {
        XCTAssertTrue(applePayReminder.exists)
        XCTAssertTrue(applePayButton.exists)
    }
}
