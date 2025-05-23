//
//  ExamplesUITests.swift
//  CardPaymentGuestUserCheckoutTests
//
//  Created by Weiping Li on 19/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

final class CardGuestUserCheckoutTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        app.launchEnvironment[UITestingEnvironmentVariable.isUITesting] = "1"
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
    func testCardPayment_oneOff_3DS_Challenge_Collection_accordionLayout() throws {
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
    private func testCardPayment(cardNumber: String, threeDSChallenge: Bool, useTabLayout: Bool = true) {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.ensureCheckoutMode(.oneOff)
        UIIntegrationDemoScreen.openSettings()
        SettingsScreen.validate()
        SettingsScreen.ensureEnvironment(.demo)
        SettingsScreen.ensureCustomerID(nil)
        SettingsScreen.ensureLayoutMode(useTabLayout: useTabLayout)
        SettingsScreen.save()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.validate()
        CardPaymentScreen.validate()
        CardPaymentScreen.payWithCard(cardNumber: cardNumber, expiry: "03/33", cvc: "333")
        if threeDSChallenge {
            ThreeDSScreen.validate()
            ThreeDSScreen.handleThreeDS()
        }
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
    }
    
    @MainActor
    func testPaymentCancelled() throws {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.validate()
        PaymentSheetScreen.cancelPayment()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.cancel)
    }
    
    @MainActor
    func test3DSCancelled() throws {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.validate()
        CardPaymentScreen.validate()
        CardPaymentScreen.payWithCard(cardNumber: "4012000300000088", expiry: "03/33", cvc: "333")
        ThreeDSScreen.validate()
        ThreeDSScreen.cancelThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.failure("3DS has been cancelled!"))
    }
}
