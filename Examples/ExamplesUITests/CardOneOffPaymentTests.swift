//
//  ExamplesUITests.swift
//  CardOneOffPaymentTests
//
//  Created by Weiping Li on 19/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

final class CardOneOffPaymentTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchEnvironment["CHECKOUT_MODE"] = "0"// 0:one-off, 1: Recurring, 2: RecurringWithIntent
        app.launchEnvironment["ENVIRONMENT"] = "0"// 0: Demo, 1: Staging, 2: Production
        app.launchEnvironment["CUSTOMER_ID"] = ""// guest user checkout
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testCardPayment_oneOff_3DS_Challenge_Collection() throws {
        testCardPayment(cardNumber: "4012000300000088", threeDSChallenge: true)
    }
    
    @MainActor
    func testCardPayment_oneOff_3DS_Challenge_NoCollection() throws {
        testCardPayment(cardNumber: "4012000300000062", threeDSChallenge: true)
    }
    
    @MainActor
    func testCardPayment_oneOff_NoChallenge_Collection() throws {
        testCardPayment(cardNumber: "4012000300000021", threeDSChallenge: false)
    }
    
    @MainActor
    func testCardPayment_oneOff_NoChallenge_NoCollection() throws {
        testCardPayment(cardNumber: "4012000300000005", threeDSChallenge: false)
    }
    
    @MainActor
    private func testCardPayment(cardNumber: String, threeDSChallenge: Bool) {
        app.launch()
        HomeScreen.validate()
        HomeScreen.pushUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.ensureCheckoutMode(.oneOff)
        UIIntegrationDemoScreen.settingsButton.tap()
        SettingsScreen.validate()
        SettingsScreen.ensureEnvironment(.demo)
        UIIntegrationDemoScreen.launchDefaultPaymentList()
        PaymentSheetScreen.validate()
        CardPaymentScreen.validate()
        CardPaymentScreen.payWithCard(cardNumber: cardNumber, expiry: "03/33", cvc: "333")
        if threeDSChallenge {
            ThreeDSScreen.handleThreeDS()
        }
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.verifyPaymentStatusAlert(
            title: "Payment successful",
            message: "Your payment has been charged"
        )
    }
    
    @MainActor
    func testPaymentCancelled() throws {
        app.launch()
        HomeScreen.validate()
        HomeScreen.pushUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.launchDefaultPaymentList()
        PaymentSheetScreen.validate()
        PaymentSheetScreen.cancelPayment()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.verifyPaymentStatusAlert(
            title: "Payment cancelled",
            message: "Your payment has been cancelled"
        )
    }
}
