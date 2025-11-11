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
        SettingsScreen.ensureEnvironment(.demo)
        SettingsScreen.ensureCustomerID(customerID)
        SettingsScreen.ensureLayoutMode(useTabLayout: useTabLayout)
        if let nextTriggerByCustomer {
            SettingsScreen.ensureNextTriggerByCustomer(nextTriggerByCustomer)
        }
        SettingsScreen.ensureForce3DS(force3DS)
        SettingsScreen.ensurePreferUnifiedSession(preferUnifiedSession)
        SettingsScreen.ensureExpressCheckout(preferUnifiedSession && preferExpressCheckout)
        SettingsScreen.save()
        UIIntegrationDemoScreen.validate()
    }
}

extension XCUIElement {
    
    func robustTap() {
        let coordinate = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.tap()
    }
}
