//
//  ConsentPaymentScreen.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

enum ConsentPaymentScreen {
    static let app = XCUIApplication()
    static let activityIndicator = app.activityIndicators.firstMatch

    // consent list
    static let addNewCardToggle = app.cells["addNewCardToggle"].buttons["Add new"]
    static let anyConsentInList = app.cells[AccessibilityIdentifiers.listedConsentCell]
    static let allConsentCells = app.cells.matching(identifier: AccessibilityIdentifiers.listedConsentCell)
    static let consentActionButton = anyConsentInList.buttons.firstMatch
    
    static let alertForRemove = app.alerts.firstMatch
    
    // selected consent
    static let selectedConsent = app.cells[AccessibilityIdentifiers.selectedConsentCell]
    static let checkoutButton = app.cells["checkoutButton"].buttons.firstMatch
    static let cvcField = app.cells["cvcField"].textFields.firstMatch
    static let changeToListButton = selectedConsent.buttons.firstMatch
    
    static var exists: Bool {
        selectedConsent.exists || addNewCardToggle.exists
    }
    static func validate() {
        if selectedConsent.exists {
            XCTAssertTrue(checkoutButton.exists)
            XCTAssert(changeToListButton.exists)
        } else {
            XCTAssertTrue(addNewCardToggle.exists)
            XCTAssertTrue(addNewCardToggle.exists)
            XCTAssertTrue(anyConsentInList.exists)
            XCTAssertTrue(consentActionButton.exists)
        }
        validateConsentIcons()
    }
    
    static var isConsentSelected: Bool {
        selectedConsent.exists
    }
    
    static func deleteFirstConsent() {
        if isConsentSelected {
            changeToListButton.tap()
        }
        let count  = allConsentCells.count
        guard count > 0 else {
            return
        }
        XCTAssert(consentActionButton.exists)
        consentActionButton.tap()
        XCTAssertTrue(alertForRemove.waitForExistence(timeout: .animationTimeout))
        XCTAssertTrue(alertForRemove.staticTexts["This option will be permanently removed from your saved payment methods."].exists)
        alertForRemove.buttons["Remove"].tap()
        _ = alertForRemove.waitForNonExistence(timeout: .animationTimeout)
        _ = activityIndicator.waitForNonExistence(timeout: .networkRequestTimeout)
        XCTAssertEqual(count, allConsentCells.count + 1)
    }
    
    static func deleteAllConsents() {
        if isConsentSelected {
            changeToListButton.tap()
        }
        while allConsentCells.count > 0 {
            deleteFirstConsent()
        }
    }
    
    static func payWithFirstConsent() {
        if !isConsentSelected {
            allConsentCells.firstMatch.tap()
        }
        XCTAssertTrue(isConsentSelected)
        if cvcField.exists {
            cvcField.tap()
            cvcField.typeText("333")
            selectedConsent.tap()
        }
        if checkoutButton.exists {
            selectedConsent.swipeUp()
        }
        checkoutButton.tap()
        XCTAssertTrue(activityIndicator.exists)
        if ThreeDSScreen.exists {
            ThreeDSScreen.validate()
            ThreeDSScreen.handleThreeDS()
        }
        selectedConsent.waitForNonExistence(timeout: .networkRequestTimeout)
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
    }
    
    static func validateConsentIcons() {
        func validateIfIconAndLabelMatched(consentCell: XCUIElement) {
            guard let label = (consentCell.staticTexts.firstMatch.value as? String)?.lowercased() else {
                return
            }
            if label.hasPrefix("visa") {
                XCTAssertTrue(consentCell.images["visa"].exists)
            } else if label.hasPrefix("union pay") {
                XCTAssertTrue(consentCell.images["unionpay"].exists)
            } else {
                // add more if necessary
            }
        }
        if selectedConsent.exists {
            validateIfIconAndLabelMatched(consentCell: selectedConsent)
        } else {
            for cell in allConsentCells.allElementsBoundByIndex {
                validateIfIconAndLabelMatched(consentCell: cell)
            }
        }
    }
}
