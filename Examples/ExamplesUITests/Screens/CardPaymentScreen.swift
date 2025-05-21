//
//  CardPaymentSection.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum CardPaymentScreen {
    static let app = XCUIApplication()
    static let cardNumberField = app.cells["cardInfo"].textFields["cardNumberTextField"]
    static let cardExpiryField = app.cells["cardInfo"].textFields["cardExpiryTextField"]
    static let cardCVCField = app.cells["cardInfo"].textFields["cardCVCTextField"]
    static let checkoutButton = app.buttons["Pay"]
    
    static func validate() {
        XCTAssertTrue(cardNumberField.exists)
        XCTAssertTrue(cardExpiryField.exists)
        XCTAssertTrue(cardCVCField.exists)
    }
    
    static func payWithCard(cardNumber: String, expiry: String, cvc: String) {
        cardNumberField.tap()
        cardNumberField.typeText(cardNumber)
        cardExpiryField.tap()
        cardExpiryField.typeText(expiry)
        cardCVCField.tap()
        cardCVCField.typeText(cvc)
        
        // dismiss keyboard
        app.staticTexts["Card Information"].tap()
        
        if !checkoutButton.exists {
            app.staticTexts["Card Information"].swipeUp()
        }
        
        checkoutButton.tap()
        XCTAssertTrue(app.activityIndicators.firstMatch.exists)
        
        checkoutButton.waitForNonExistence(timeout: 5)
    }
}
