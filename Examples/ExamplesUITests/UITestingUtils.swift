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
    static let unionPay = "6262000000000000"
}

@MainActor
extension XCTestCase {
    
    func launchAppAndEnsureSettings(_ app: XCUIApplication,
                                    checkoutMode: CheckoutMode,
                                    customerID: String = "",
                                    env: SettingsScreen.Environment = .demo,
                                    useTabLayout: Bool = true,
                                    nextTriggerByCustomer: Bool? = nil,
                                    force3DS: Bool = false) {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.ensureCheckoutMode(checkoutMode)
        UIIntegrationDemoScreen.openSettings()
        SettingsScreen.validate()
        SettingsScreen.ensureEnvironment(.demo)
        SettingsScreen.ensureCustomerID(customerID)
        SettingsScreen.ensureForce3DS(false)
        SettingsScreen.ensureLayoutMode(useTabLayout: useTabLayout)
        if let nextTriggerByCustomer {
            SettingsScreen.ensureNextTriggerByCustomer(nextTriggerByCustomer)
        }
        SettingsScreen.ensureForce3DS(force3DS)
        SettingsScreen.save()
        UIIntegrationDemoScreen.validate()
    }
}
