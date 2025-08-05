//
//  ApplePayTests.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 28/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

final class ApplePayTests: XCTestCase {
    
    var app: XCUIApplication!
    
    private var customerId: String = ""
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()

        customerId = ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.customerID] ?? ""
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testApplePay_cancel() throws {
        // UI tests must launch the application that they test.
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId
        )
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence(.animationTimeout)
        XCTAssertTrue(PaymentSheetScreen.applePayButton.exists)
        PaymentSheetScreen.applePayButton.tap()
        ApplePaymentSheet.waitForExistence(.animationTimeout)
        ApplePaymentSheet.cancelPayment()
        PaymentSheetScreen.validate()
        PaymentSheetScreen.cancelPayment()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.cancel)
    }
    
    @MainActor
    func testApplePay_oneOff() throws {
        testApplePay(checkoutMode: .oneOff)
    }
    
    @MainActor
    func testApplePay_recurring() throws {
        testApplePay(checkoutMode: .recurring, nextTriggerByCustomer: false)
    }
    
    @MainActor
    func testApplePay_recurringWithIntent() throws {
        testApplePay(checkoutMode: .recurringWithIntent, nextTriggerByCustomer: false)
    }
    
    @MainActor
    private func testApplePay(checkoutMode: CheckoutMode, nextTriggerByCustomer: Bool? = nil) {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: checkoutMode,
            customerID: customerId,
            nextTriggerByCustomer: nextTriggerByCustomer
        )
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence(.animationTimeout)
        XCTAssertTrue(PaymentSheetScreen.applePayButton.exists)
        PaymentSheetScreen.applePayButton.tap()
        ApplePaymentSheet.waitForExistence()
        ApplePaymentSheet.confirmPayment()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
    }
}
