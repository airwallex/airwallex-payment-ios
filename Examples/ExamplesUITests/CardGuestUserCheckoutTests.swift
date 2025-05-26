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
    func testCardPayment_oneOff_3DS_Combined() throws {
        testCardPayment(cardNumber: TestCards.visa3DS, threeDSChallenge: true)
    }
    
    @MainActor
    func testCardPayment_oneOff_3DS_Combined_accordionLayout() throws {
        testCardPayment(cardNumber: TestCards.visa3DS, threeDSChallenge: true, useTabLayout: false)
    }
    
    @MainActor
    func testCardPayment_oneOff_3DS_Explicit() throws {
        testCardPayment(cardNumber: "4012000300000062", threeDSChallenge: true)
    }
    
    @MainActor
    func testCardPayment_oneOff_3DS_Implicit() throws {
        testCardPayment(cardNumber: "4012000300000021", threeDSChallenge: false)
    }
    
    @MainActor
    func testCardPayment_oneOff_3DS_None() throws {
        testCardPayment(cardNumber: TestCards.visa, threeDSChallenge: false)
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
        SettingsScreen.ensureForce3DS(false)
        SettingsScreen.save()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        CardPaymentScreen.payWithCard(
            cardNumber: cardNumber,
            canSaveCard: false
        )
        if threeDSChallenge {
            ThreeDSScreen.validate()
            ThreeDSScreen.handleThreeDS()
        }
        PaymentSheetScreen.waitForNonExistence()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
    }
    
    @MainActor
    func testPaymentCancelled() throws {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        PaymentSheetScreen.cancelPayment()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.cancel)
    }
    
    @MainActor
    func test3DSCancelled() throws {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: false
        )
        ThreeDSScreen.validate()
        ThreeDSScreen.cancelThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.failure)
    }
}
