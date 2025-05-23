//
//  CardRegisteredUserCheckoutTests.swift
//  ExamplesUITests
//
//  Created by Weiping Li on 21/5/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest

final class CardRegisteredUserCheckoutTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        app.launchEnvironment[UITestingEnvironmentVariable.isUITesting] = "1"
        // wpdebug set this in bitrise intead
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    @MainActor
    func testOneOffPayment_noSave() throws {
        launchAppAndEnsureSettings(checkoutMode: .oneOff)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        if ConsentPaymentScreen.exists {
            ConsentPaymentScreen.deleteAllConsents()
        }
        XCTAssertTrue(CardPaymentScreen.exists)
        CardPaymentScreen.payWithCard(cardNumber: TestCards.visa, save: false)
        // check no consents saved
        UIIntegrationDemoScreen.openDefaultPaymentList()
        XCTAssertTrue(CardPaymentScreen.exists)
        PaymentSheetScreen.cancelPayment()
    }
    
    @MainActor
    func testOneOffPayment_saveCard_tabLayout() throws {
        try testOneOffPayment_saveCard(useTabLayout: true)
    }
    
    @MainActor
    func testOneOffPayment_saveCard_accordionLayout() throws {
        try testOneOffPayment_saveCard(useTabLayout: false)
    }
    
    @MainActor
    private func testOneOffPayment_saveCard(useTabLayout: Bool) throws {
        // first card payment
        launchAppAndEnsureSettings(checkoutMode: .oneOff, useTabLayout: useTabLayout)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        if ConsentPaymentScreen.exists {
            ConsentPaymentScreen.deleteAllConsents()
        }
        CardPaymentScreen.payWithCard(cardNumber: TestCards.visa3DS, save: true)
        
        // pay with consent
        UIIntegrationDemoScreen.openDefaultPaymentList()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.payWithFirstConsent()
        
        // save another card
        UIIntegrationDemoScreen.openDefaultPaymentList()
        if ConsentPaymentScreen.isConsentSelected {
            ConsentPaymentScreen.changeToListButton.tap()
        }
        ConsentPaymentScreen.addNewCardToggle.tap()
        CardPaymentScreen.validate()
        CardPaymentScreen.payWithCard(cardNumber: TestCards.unionPay, save: true)
        
        // pay with new consent
        UIIntegrationDemoScreen.openDefaultPaymentList()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.payWithFirstConsent()
        
        // delete all consents
        UIIntegrationDemoScreen.openDefaultPaymentList()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllConsents()
    }
    
    @MainActor
    func testRecurringPayment() throws {
        testRecurringPayemnt(withIntent: false)
    }
    
    @MainActor
    func testRecurringWithIntentPayment() throws {
        testRecurringPayemnt(withIntent: true)
    }
    
    @MainActor
    private func testRecurringPayemnt(withIntent: Bool) {
        let checkoutMode: CheckoutMode = withIntent ? .recurringWithIntent : .recurring
        // delete saved consent if exists
        launchAppAndEnsureSettings(checkoutMode: .oneOff)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        if ConsentPaymentScreen.exists {
            ConsentPaymentScreen.deleteAllConsents()
        }
        PaymentSheetScreen.cancelPayment()
        
        // card payment with recurring mode
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.ensureCheckoutMode(checkoutMode)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        CardPaymentScreen.payWithCard(
            cardNumber: TestCards.visa,
            checkoutMode: .recurring
        )
        
        // pay with consent
        UIIntegrationDemoScreen.ensureCheckoutMode(.oneOff)
        UIIntegrationDemoScreen.openDefaultPaymentList()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.payWithFirstConsent()
        
        // delete all consents
        UIIntegrationDemoScreen.openDefaultPaymentList()
        ConsentPaymentScreen.validate()
        ConsentPaymentScreen.deleteAllConsents()
    }
}

@MainActor
private extension CardRegisteredUserCheckoutTests {
    
    func launchAppAndEnsureSettings(checkoutMode: CheckoutMode,
                                    env: SettingsScreen.Environment = .demo,
                                    customerID: String? = nil,
                                    useTabLayout: Bool = true) {
        app.launch()
        HomeScreen.validate()
        HomeScreen.openUIIntegrationDemos()
        UIIntegrationDemoScreen.validate()
        UIIntegrationDemoScreen.ensureCheckoutMode(checkoutMode)
        UIIntegrationDemoScreen.openSettings()
        SettingsScreen.validate()
        SettingsScreen.ensureEnvironment(.demo)
        if let customerID {
            SettingsScreen.ensureCustomerID(customerID)
        } else {
            let customerID = ProcessInfo.processInfo.environment[UITestingEnvironmentVariable.customerID]
            SettingsScreen.ensureCustomerID(customerID)
        }
        SettingsScreen.ensureForce3DS(false)
        SettingsScreen.ensureLayoutMode(useTabLayout: useTabLayout)
        SettingsScreen.save()
        UIIntegrationDemoScreen.validate()
    }
}
