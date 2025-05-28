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
    static let networkRequestTimeout: TimeInterval = 12
    
    static let shortTimeout: TimeInterval = 2
    static let mediumTimeout: TimeInterval = 6
    static let longTimeout: TimeInterval = 18
    static let longLongTimeout: TimeInterval = 36
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
                                    customerID: String? = nil,
                                    env: SettingsScreen.Environment = .demo,
                                    useTabLayout: Bool = true) {
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
        SettingsScreen.save()
        UIIntegrationDemoScreen.validate()
    }
}
