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
    static let activityIndicator = app.activityIndicators.firstMatch
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
                            expiry: String = "03/33",
                            cvc: String = "333",
                            checkoutMode: CheckoutMode = .oneOff,
                            save: Bool = true) {
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
        
        if checkoutMode == .oneOff {
            if  saveCardToggle.isSelected != save {
                saveCardToggle.tap()
                XCTAssert(saveCardToggle.isSelected == save)
            }
        }
        
        checkoutButton.tap()
        XCTAssertTrue(activityIndicator.exists)
        if ThreeDSScreen.exists {
            ThreeDSScreen.validate()
            ThreeDSScreen.handleThreeDS()
        }
        
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
    }
}
