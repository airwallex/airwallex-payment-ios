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
    static let alertMessage = app.alerts.firstMatch
    static let cardInformationLabel = app.staticTexts["Card Information"].firstMatch
    
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
        
        testCardInfoValidation()
        
        cardNumberField.robustTap()
        cardNumberField.typeText(cardNumber)
        cardExpiryField.robustTap()
        cardExpiryField.typeText(expiry)
        cardCVCField.robustTap()
        cardCVCField.typeText(cvc)
        
        // dismiss keyboard
        app.staticTexts["Card Information"].robustTap()
        
        if !checkoutButton.exists {
            app.staticTexts["Card Information"].swipeUp()
        }
        
        while !checkoutButton.exists {
            cardInfoCell.swipeUp(velocity: .slow)
        }
        
        if canSaveCard {
            if saveCardToggle.isSelected != shouldSave {
                saveCardToggle.robustTap()
                XCTAssert(saveCardToggle.isSelected == shouldSave)
            }
        }
        
        while !(checkoutButton.exists && checkoutButton.isHittable) {
            cardInfoCell.swipeUp(velocity: .slow)
        }
        
        checkoutButton.robustTap()
        XCTAssertTrue(activityIndicator.exists)
        activityIndicator.waitForNonExistence(timeout: .networkRequestTimeout)
    }
    
    static func dismissKeyboard() {
        XCTAssertTrue(cardInformationLabel.exists)
        cardInformationLabel.robustTap()
    }
    
    static func testCardInfoValidation() {
        
        while !checkoutButton.exists {
            cardInfoCell.swipeUp(velocity: .slow)
        }
        
        checkoutButton.robustTap()
        XCTAssertFalse(activityIndicator.exists)
        XCTAssertTrue(alertMessage.waitForExistence(timeout: .animationTimeout))
        XCTAssertTrue(alertMessage.staticTexts["Card number is required"].exists)
        alertMessage.buttons["Close"].robustTap()
        alertMessage.waitForNonExistence(timeout: .shortTimeout)
        XCTAssertTrue(app.staticTexts["Card number is required"].exists)
        
        while !cardInformationLabel.exists {
            cardInfoCell.swipeDown(velocity: .slow)
        }
    }
}
