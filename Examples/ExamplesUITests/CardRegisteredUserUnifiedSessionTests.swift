//
//  CardRegisteredUserUnifiedSessionTests.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 4/9/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

@MainActor final class CardRegisteredUserUnifiedSessionTests: XCTestCase {
    
    var app: XCUIApplication!
    private var customerId: String = ""
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        
        // expect to have MIT consent exist for this user
        customerId = ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.customerID_2] ?? ""
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// - verify consent of TestCards.visa exists
    /// - pay with TestCards.visa3DS
    /// - verify no new consent saved (last 4 digit)
    func testOneOffPayment() {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId,
            preferUnifiedSession: true
        )
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.addNewCardToggle.tap()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: true,
            shouldSave: false
        )
        
        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        // check no consents saved
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
    }
    
    /// pay with MIT consent
    /// pay with CIT consent
    func testOneOffPaymentWithConsent() {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId,
            preferUnifiedSession: true
        )
        // paye with MIT
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.payWithFirstConsent(cit: false)
        
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // pay with CIT
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validateConsentCount(cit: 1, mit: 0)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.payWithFirstConsent(cit: true)
        
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // clean up
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
    }
    
    /// pay with TestCards.visa3DS
    /// verify new consent created (last 4 digit)
    /// pay with new cit consent
    /// remove new CIT consent
    func testOneOffPayment_saveCard() {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: .oneOff,
            customerID: customerId,
            preferUnifiedSession: true
        )
        // pay with TestCards.visa3DS
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.addNewCardToggle.tap()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: true,
            shouldSave: true
        )
        
        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // validate new consent saved
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validateConsentCount(cit: 1, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa3DS.suffix(4))
        )
        
        // pay with new cit consent
        ConsentPaymentScreen.payWithFirstConsent(cit: true)
        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // clean up
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
    }
    
    func testCreateCITConsentWithCard() {
        testCreateCITConsentWithCard(withPayment: false)
    }
    
    func testCreateCITConsentWithCardWithPayment() {
        testCreateCITConsentWithCard(withPayment: true)
    }
    
    func testCreateMITConsentWithCard() {
        testCreateMITConsentWithCard(withPayment: false)
    }
    
    func testCreateMITConsentWithCardWithPayment() {
        testCreateMITConsentWithCard(withPayment: true)
    }
    
    func testCreateConsentFromExistingConsent() {
        testCreateConsentFromExistingConsent(withPayment: false)
    }
    
    func testCreateConsentFromExistingConsentWithPayment() {
        testCreateConsentFromExistingConsent(withPayment: true)
    }
}

private extension CardRegisteredUserUnifiedSessionTests {
    
    func testCreateCITConsentWithCard(withPayment: Bool) {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: withPayment ? .recurringWithIntent : .recurring,
            customerID: customerId,
            nextTriggerByCustomer: true,
            preferUnifiedSession: true
        )
        // pay with TestCards.visa3DS
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.addNewCardToggle.tap()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa3DS,
            canSaveCard: false
        )
        
        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // validate new consent saved
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validateConsentCount(cit: 1, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa3DS.suffix(4))
        )
        
        // pay with new cit consent
        ConsentPaymentScreen.payWithFirstConsent(cit: true)
        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // clean up
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
    }
    
    /// pay with TestCards.visa
    /// mit consent saved with same card will have the same fingerprint,
    /// so only one of them will be displayed
    func testCreateMITConsentWithCard(withPayment: Bool) {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: withPayment ? .recurringWithIntent : .recurring,
            customerID: customerId,
            nextTriggerByCustomer: false,
            preferUnifiedSession: true
        )
        // pay with TestCards.visa
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.addNewCardToggle.tap()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa,
            canSaveCard: false
        )
        
        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // clean up
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
    }
    
    /// creat CIT consent with MIT consent of TestCards.visa
    /// create MIT consent with CIT consent of TestCards.visa
    func testCreateConsentFromExistingConsent(withPayment: Bool) {
        launchAppAndEnsureSettings(
            app,
            checkoutMode: withPayment ? .recurringWithIntent : .recurring,
            customerID: customerId,
            nextTriggerByCustomer: true,
            preferUnifiedSession: true
        )
        // create CIT consent from MIT consent
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.payWithFirstConsent(cit: false)
//        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // create MIT consent from CIT consent
        UIIntegrationDemoScreen.openSettings()
        SettingsScreen.ensureNextTriggerByCustomer(false)
        SettingsScreen.close()
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.validateConsentCount(cit: 1, mit: 0)
        ConsentPaymentScreen.validateFirstConsent(
            prefix: "Visa",
            last4: String(TestCards.visa.suffix(4))
        )
        ConsentPaymentScreen.payWithFirstConsent(cit: true)
//        ThreeDSScreen.handleThreeDS()
        UIIntegrationDemoScreen.verifyAlertForPaymentStatus(.success)
        
        // clean up
        UIIntegrationDemoScreen.openDefaultPaymentList()
        PaymentSheetScreen.waitForExistence()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllCITConsents()
        ConsentPaymentScreen.validateConsentCount(cit: 0, mit: 1)
    }
}
