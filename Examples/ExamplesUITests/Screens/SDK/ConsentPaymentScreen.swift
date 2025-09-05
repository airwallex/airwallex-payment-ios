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
    static let activityIndicator = app.otherElements["loadingSpinnerView"].firstMatch

    // consent list
    static let addNewCardToggle = app.cells["addNewCardToggle"].buttons["Add new"]
    
    // all consents
    static let consentCellsPredicate = NSPredicate(format: "identifier BEGINSWITH %@", AccessibilityIdentifiers.listedConsentCell)
    static let firstConsentInList = app.cells.matching(consentCellsPredicate).firstMatch
    static let allConsentCells = app.cells.matching(consentCellsPredicate)
    
    // cit consents
    static let firstCITConsentInList = app.cells[AccessibilityIdentifiers.listedCITConsentCell].firstMatch
    static let allCITConsentCells = app.cells.matching(identifier: AccessibilityIdentifiers.listedCITConsentCell)
    static let firstCITConsentActionButton = firstCITConsentInList.buttons.firstMatch
    
    // mit consents
    static let allMITConsentCells = app.cells.matching(identifier: AccessibilityIdentifiers.listedMITConsentCell)
    static let firstMITConsentInList = app.cells[AccessibilityIdentifiers.listedMITConsentCell].firstMatch
    
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
            XCTAssertTrue(firstConsentInList.exists)
        }
        validateConsentIcons()
    }
    
    static var isConsentSelected: Bool {
        selectedConsent.exists
    }
    
    static func deleteFirstCITConsent() {
        if isConsentSelected {
            changeToListButton.robustTap()
        }
        let count = allCITConsentCells.count
        guard count > 0 else {
            return
        }
        XCTAssert(firstCITConsentActionButton.exists)
        firstCITConsentActionButton.robustTap()
        XCTAssertTrue(alertForRemove.waitForExistence(timeout: .animationTimeout))
        XCTAssertTrue(alertForRemove.staticTexts["This option will be permanently removed from your saved payment methods."].exists)
        alertForRemove.buttons["Remove"].robustTap()
        _ = alertForRemove.waitForNonExistence(timeout: .animationTimeout)
        _ = activityIndicator.waitForNonExistence(timeout: .networkRequestTimeout)
        XCTAssertEqual(count, allCITConsentCells.count + 1)
    }
    
    static func deleteAllCITConsents() {
        validate()
        if isConsentSelected {
            changeToListButton.robustTap()
        }
        while allCITConsentCells.count > 0 {
            deleteFirstCITConsent()
        }
        if !addNewCardToggle.waitForNonExistence(timeout: .animationTimeout) {
            XCTAssertTrue(allMITConsentCells.count > 0)
        }
    }
    
    static func payWithFirstConsent(cit: Bool) {
        validate()
        if !isConsentSelected {
            if cit {
                allCITConsentCells.firstMatch.robustTap()
            } else {
                allMITConsentCells.firstMatch.robustTap()
            }
        }
        XCTAssertTrue(isConsentSelected)
        if cvcField.exists {
            cvcField.robustTap()
            cvcField.typeText("333")
            selectedConsent.robustTap()
        }
        if checkoutButton.exists {
            selectedConsent.swipeUp()
        }
        checkoutButton.robustTap()
        XCTAssertTrue(activityIndicator.exists)
    }
    
    static func validateConsentIcons() {
        func validateIfIconAndLabelMatched(consentCell: XCUIElement) {
            let label = consentCell.staticTexts.firstMatch.label.lowercased()
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
    
    static func validateConsentCount(cit: Int, mit: Int) {
        if isConsentSelected {
            changeToListButton.tap()
        }
        XCTAssertEqual(allCITConsentCells.count, cit)
        XCTAssertEqual(allMITConsentCells.count, mit)
    }
    
    static func validateFirstConsent(prefix: String, last4: String) {
        if isConsentSelected {
            changeToListButton.tap()
        }
        let label = firstConsentInList.staticTexts.firstMatch.label
        XCTAssertTrue(label.hasPrefix(prefix))
        XCTAssertTrue(label.hasSuffix(last4))
    }
}
