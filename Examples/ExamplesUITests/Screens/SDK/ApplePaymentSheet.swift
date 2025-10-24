//
//  ApplePaymentSheet.swift
//  Examples
//
//  Created by Weiping Li on 28/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

enum ApplePaymentSheet {
    static let applePaySheet = XCUIApplication(bundleIdentifier: "com.apple.PassbookUIService")
    static let cardButton = applePaySheet.buttons.containing(NSPredicate(format: "label CONTAINS 'Simulated Card - '")).firstMatch
    static let payButton = applePaySheet.buttons["Pay with Passcode"]
    static var cancelButton: XCUIElement {
        if #available(iOS 26.0, *) {
            return applePaySheet.buttons["dismiss"]
        } else {
            return applePaySheet.buttons["close"]
        }
    }
    
    static func waitForExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(cancelButton.waitForExistence(timeout: timeout))
        XCTAssertTrue(cardButton.exists)
        XCTAssertTrue(payButton.exists)
    }
    
    static func waitForNonExistence(_ timeout: TimeInterval = .networkRequestTimeout) {
        XCTAssertTrue(cancelButton.waitForNonExistence(timeout: timeout))
    }
    
    static func cancelPayment() {
        //  cancelButton.robustTap()
        //  not sure why but robust tap not working for this cancel button
        cancelButton.tap()
        waitForNonExistence()
    }
    
    static func confirmPayment() {
        payButton.robustTap()
        waitForNonExistence(.networkRequestTimeout)
    }
}
