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
    static let checkoutButton = app.cells["checkoutButton"].buttons.firstMatch
    static let activityIndicator = app.otherElements["loadingSpinnerView"].firstMatch
    static let cardInfoCell = app.cells["cardInfo"]
    static let consentToggle = app.cells["consentToggle"].buttons["Keep using saved cards"]
    static let saveCardToggle = app.cells["saveCardToggle"].buttons.firstMatch
    
    static var exists: Bool {
        cardInfoCell.exists
    }
    
    static func validate() {
        XCTAssertTrue(cardNumberField.exists)
        XCTAssertTrue(cardExpiryField.exists)
        XCTAssertTrue(cardCVCField.exists)
    }
    
    static func payWithCard(cardNumber: String,
                            canSaveCard: Bool,
                            shouldSave: Bool = true,
                            expiry: String = "03/33",
                            cvc: String = "333") {
        validate()
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
        
        if !checkoutButton.exists {
            cardInfoCell.swipeUp()
        }
        
        if canSaveCard {
            if saveCardToggle.isSelected != shouldSave {
                saveCardToggle.tap()
                XCTAssert(saveCardToggle.isSelected == shouldSave)
            }
        }
        
        checkoutButton.tap()
        XCTAssertTrue(activityIndicator.exists)
    }
}
