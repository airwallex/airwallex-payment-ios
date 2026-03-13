//
//  EmbeddedElementTests.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 5/3/26.
//  Copyright © 2026 Airwallex. All rights reserved.
//

import XCTest

@MainActor
final class EmbeddedElementTests: XCTestCase {

    var app: XCUIApplication!

    private var customerId: String = ""

    override func setUpWithError() throws {
        // UI tests must launch the application that they test.
        app = XCUIApplication()

        customerId = ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.customerID_3] ?? ""

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: Apple Pay

    func testApplePay_PrimaryButton() throws {
        launchPaymentElement(layout: .tab, inline: false)
        PaymentSheetScreen.applePayButton.robustTap()
        ApplePaymentSheet.waitForExistence()
        ApplePaymentSheet.confirmPayment()
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.success)
    }

    func testApplePay_PrimaryButton_Cancel() throws {
        // stay in EmbeddedElementScreen
        launchPaymentElement(layout: .accordion, inline: false)
        PaymentSheetScreen.applePayButton.robustTap()
        ApplePaymentSheet.waitForExistence()
        ApplePaymentSheet.cancelPayment()
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.cancel)
        EmbeddedElementScreen.validate()
        EmbeddedElementScreen.goBack()
        UIIntegrationDemoScreen.waitForExistence(.animationTimeout)
    }

    func testApplePay_Inline_TabLayout() throws {
        launchPaymentElement(layout: .tab, inline: true)
        XCTAssertTrue(EmbeddedElementScreen.applePayMethodCell.exists)
        if !ApplePaymentMethodView.applePayButton.exists {
            EmbeddedElementScreen.applePayMethodCell.robustTap()
            ApplePaymentMethodView.validate()
        }
        ApplePaymentMethodView.applePayButton.robustTap()
        ApplePaymentSheet.waitForExistence()
        ApplePaymentSheet.confirmPayment()
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.success)
    }

    func testApplePay_Inline_AccordionLayout() throws {
        launchPaymentElement(layout: .accordion, inline: true)
        if EmbeddedElementScreen.applePayMethodCell.exists {
            EmbeddedElementScreen.applePayMethodCell.robustTap()
        }
        XCTAssertFalse(EmbeddedElementScreen.applePayMethodCell.exists)
        ApplePaymentMethodView.validate()
        XCTAssertTrue(ApplePaymentMethodView.accordionKey.exists)
        ApplePaymentMethodView.applePayButton.robustTap()
        ApplePaymentSheet.waitForExistence()
        ApplePaymentSheet.confirmPayment()
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.success)
    }

    // MARK: Card

    func testCard_TabLayout() throws {
        payWithCardAndCITConsent(layout: .tab)
    }

    func testCard_AccordionLayout() throws {
        payWithCardAndCITConsent(layout: .accordion)
    }

    func testCard_AddCardElement_saveCardAndDelete() throws {
        // launch embedded add card element
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId,
            nextTriggerByCustomer: true
        )
        // delete all consents
        openEmbeddedElementAndDeleteAllCITConsents()
        EmbeddedElementScreen.goBack()

        // open add card element
        UIIntegrationDemoScreen.openEmbeddedElement(elementStyle: .addCard)
        EmbeddedElementScreen.waitForPaymentElementLoaded()

        CardPaymentMethodView.validate()
        // always use tab layout
        XCTAssertFalse(CardPaymentMethodView.accordionKey.exists)

        // pay with card requires 3DS
        CardPaymentMethodView.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: true,
            shouldSave: true
        )

        ThreeDSScreen.handleThreeDS()
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.success)

        // delete all consents
        openEmbeddedElementAndDeleteAllCITConsents()
    }

}

extension EmbeddedElementTests {

    func launchPaymentElement(layout: Layout, inline: Bool) {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId,
            nextTriggerByCustomer: true,
            useTabLayout: layout == .tab
        )
        if inline {
            UIIntegrationDemoScreen.openEmbeddedElement(elementStyle: .paymentSheetInlineApplePay)
        } else {
            UIIntegrationDemoScreen.openEmbeddedElement(elementStyle: .paymentSheetDefault)
        }
        EmbeddedElementScreen.waitForPaymentElementLoaded()
    }

    func openEmbeddedElementAndDeleteAllCITConsents() {
        UIIntegrationDemoScreen.openEmbeddedElement(elementStyle: .paymentSheetDefault)
        EmbeddedElementScreen.waitForExistence()
        if ConsentPaymentMethodView.exists {
            ConsentPaymentMethodView.deleteAllCITConsents()
        }
        CardPaymentMethodView.validate()
    }

    func payWithCardAndCITConsent(layout: Layout) {
        // launch embedded add card element
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId,
            nextTriggerByCustomer: true,
            useTabLayout: layout == .tab
        )
        // remove existing consents
        openEmbeddedElementAndDeleteAllCITConsents()

        // pay with card requires 3DS
        CardPaymentMethodView.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: true,
            shouldSave: true
        )

        ThreeDSScreen.handleThreeDS()
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.success)

        // pay with consent
        UIIntegrationDemoScreen.openEmbeddedElement(elementStyle: .paymentSheetDefault)
        EmbeddedElementScreen.waitForPaymentElementLoaded()
        ConsentPaymentMethodView.payWithFirstConsent(cit: true)

        ThreeDSScreen.handleThreeDS()
        EmbeddedElementScreen.loadingIndicator.waitForNonExistence(timeout: .networkRequestTimeout)
        EmbeddedElementScreen.verifyAlertForPaymentStatus(.success)

        // delete all consents
        openEmbeddedElementAndDeleteAllCITConsents()
    }
}
