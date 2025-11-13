//
//  ExamplesUITests.swift
//  CardPaymentGuestUserCheckoutTests
//
//  Created by Weiping Li on 19/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

@MainActor
final class CardGuestUserCheckoutTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCardPayment_oneOff_3DS_Combined() throws {
        testCardPayment(cardNumber: TestCards.visa3DS, threeDSChallenge: true)
    }
    
    func testCardPayment_oneOff_3DS_Combined_legacySession() throws {
        testCardPayment(cardNumber: TestCards.visa3DS, preferUnifiedSession: false, threeDSChallenge: true)
    }
    
    func testCardPayment_oneOff_3DS_Combined_accordionLayout() throws {
        testCardPayment(cardNumber: TestCards.visa3DS, threeDSChallenge: true, useTabLayout: false)
    }
    
    func testCardPayment_oneOff_3DS_Explicit() throws {
        testCardPayment(cardNumber: "4012000300000062", threeDSChallenge: true)
    }
    
    func testCardPayment_oneOff_3DS_Implicit() throws {
        testCardPayment(cardNumber: "4012000300000021", threeDSChallenge: false)
    }
    
    func testCardPayment_oneOff_3DS_None() throws {
        testCardPayment(cardNumber: TestCards.visa, threeDSChallenge: false)
    }
    
    func testCardPayment_oneOff_3DS_None_no_express_checkout() throws {
        testCardPayment(cardNumber: TestCards.visa, threeDSChallenge: false)
    }
    
    private func testCardPayment(cardNumber: String,
                                 preferUnifiedSession: Bool = true,
                                 preferExpressCheckout: Bool = true,
                                 threeDSChallenge: Bool,
                                 useTabLayout: Bool = true) {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: "",
            force3DS: false,
            preferUnifiedSession: preferUnifiedSession,
            preferExpressCheckout: preferExpressCheckout,
            useTabLayout: useTabLayout
        )
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        CardPaymentScreen.payWithCard(
            cardNumber: cardNumber,
            canSaveCard: false
        )
        if threeDSChallenge {
            ThreeDSScreen.handleThreeDS()
        }
        PaymentSheetScreen.waitForNonExistence()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
    }
    
    func testPaymentCancelled() throws {
        launchAppAndEnsureSettings(app, checkoutMode: .oneOff)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        PaymentSheetScreen.cancelPayment()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.cancel)
    }
    
    func test3DSCancelled() throws {
        launchAppAndEnsureSettings(app, checkoutMode: .oneOff)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: false
        )
        ThreeDSScreen.waitForExistence(.longLongTimeout)
        ThreeDSScreen.cancelThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.failure)
    }
}
