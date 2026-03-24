//
//  UITestingUtils.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import XCTest

extension TimeInterval {
    static let animationTimeout: TimeInterval = 2
    static let networkRequestTimeout: TimeInterval = 30
    
    static let shortTimeout: TimeInterval = 2
    static let mediumTimeout: TimeInterval = 15
    static let longTimeout: TimeInterval = 30
    static let longLongTimeout: TimeInterval = 60
}

enum TestCards {
    static let visa = "4111111111111111"
    static let visa3DS = "4012000300000088"
    static let unionPay = "6252470144444939"
}

enum PaymentStatus {
    case success
    case failure
    case cancel
}

enum Layout {
    case accordion
    case tab
}

@MainActor
extension XCTestCase {
    
    func launchAppAndEnsureSettings(_ app: XCUIApplication,
                                    checkoutMode: CheckoutMode,
                                    customerID: String = "",
                                    env: SettingsScreen.Environment = .demo,
                                    force3DS: Bool = false,
                                    nextTriggerByCustomer: Bool? = nil,
                                    preferUnifiedSession: Bool = true,
                                    preferExpressCheckout: Bool = true,
                                    useTabLayout: Bool = true) {
        app.launchEnvironment[UITestingEnvironmentVariable.isUITesting] = "1"
        app.launchEnvironment[UITestingEnvironmentVariable.mockApplePayToken] = ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.mockApplePayToken]
        app.launch()
        HomeScreen.waitForExistence(.longTimeout)
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.ensureCheckoutMode(checkoutMode)
        UIIntegrationDemoScreen.openSettings()
        SettingsScreen.validate()
        SettingsScreen.ensureEnvironment(env)
        SettingsScreen.ensureLayoutMode(useTabLayout: useTabLayout)
        if let nextTriggerByCustomer {
            SettingsScreen.ensureNextTriggerByCustomer(nextTriggerByCustomer)
        }
        SettingsScreen.ensureForce3DS(force3DS)
        SettingsScreen.ensurePreferUnifiedSession(preferUnifiedSession)
        SettingsScreen.ensureExpressCheckout(preferUnifiedSession && preferExpressCheckout)
        SettingsScreen.ensureCustomerID(customerID)
        SettingsScreen.save()
        UIIntegrationDemoScreen.validate()
    }
}

extension XCUIElement {

    /// Scrolls the element into the center of the screen (away from edges/home indicator)
    /// then taps it. This avoids issues where elements near the bottom edge are obscured
    /// by the home indicator bar.
    func robustTap() {
        scrollIntoView()
        tap()
    }

    /// Swipes the element into a safe area of the screen if it's near the bottom edge
    /// where it could be obscured by the home indicator bar.
    private func scrollIntoView() {
        guard exists else { return }
        let app = XCUIApplication()
        let window = app.windows.firstMatch

        let elementFrame = frame
        let windowFrame = window.frame
        guard !windowFrame.isEmpty else { return }

        // If the element's bottom edge is within 80pt of the screen bottom,
        // it may be obscured by the home indicator. Swipe up to bring it into view.
        let bottomMargin: CGFloat = 80
        if elementFrame.maxY > windowFrame.maxY - bottomMargin {
            let startCoord = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
            let endCoord = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            startCoord.press(forDuration: 0.05, thenDragTo: endCoord)
        }
    }
}
