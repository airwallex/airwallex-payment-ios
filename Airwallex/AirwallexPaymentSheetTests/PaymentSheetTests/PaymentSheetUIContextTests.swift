//
//  PaymentSheetUIContextTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2026/3/9.
//  Copyright © 2026 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import PassKit
import UIKit
import XCTest

@MainActor
class PaymentSheetUIContextTests: XCTestCase {

    var sut: PaymentSheetUIContext!

    override func setUp() {
        super.setUp()
        sut = PaymentSheetUIContext()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInit_DefaultValues() {
        XCTAssertNil(sut.viewController)
        XCTAssertNil(sut.delegate)
        XCTAssertNil(sut.dismissAction)
        XCTAssertTrue(sut.hasPaymentUI)
        XCTAssertEqual(sut.layout, .tab)
        XCTAssertTrue(sut.showsApplePayAsPrimaryButton)
        XCTAssertNil(sut.currentPaymentMethod)
        XCTAssertNil(sut.paymentElement)
        XCTAssertFalse(sut.isEmbedded)
    }

    func testInit_WithDelegate() {
        let delegate = MockPaymentResultDelegate()
        sut = PaymentSheetUIContext(delegate: delegate)
        XCTAssertTrue(sut.delegate === delegate)
    }

    // MARK: - Properties

    func testViewControllerIsWeak() {
        var vc: UIViewController? = UIViewController()
        sut.viewController = vc
        XCTAssertNotNil(sut.viewController)
        vc = nil
        XCTAssertNil(sut.viewController)
    }

    func testDelegateIsWeak() {
        var delegate: MockPaymentResultDelegate? = MockPaymentResultDelegate()
        sut = PaymentSheetUIContext(delegate: delegate)
        XCTAssertNotNil(sut.delegate)
        delegate = nil
        XCTAssertNil(sut.delegate)
    }

    func testPaymentElementIsWeak() {
        let methodProvider = MockMethodProvider(methods: [], consents: [])
        var element: AWXPaymentElement? = AWXPaymentElement(
            methodProvider: methodProvider,
            delegate: MockPaymentResultDelegate()
        )
        sut.paymentElement = element
        XCTAssertNotNil(sut.paymentElement)
        XCTAssertTrue(sut.isEmbedded)
        element = nil
        XCTAssertNil(sut.paymentElement)
        XCTAssertFalse(sut.isEmbedded)
    }

    func testIsEmbedded_ReturnsTrueWhenPaymentElementSet() {
        let methodProvider = MockMethodProvider(methods: [], consents: [])
        let element = AWXPaymentElement(
            methodProvider: methodProvider,
            delegate: MockPaymentResultDelegate()
        )
        sut.paymentElement = element
        XCTAssertTrue(sut.isEmbedded)
        _ = element // keep alive
    }

    func testIsEmbedded_ReturnsFalseWhenPaymentElementNil() {
        XCTAssertFalse(sut.isEmbedded)
    }

    func testLayout_CanBeChanged() {
        XCTAssertEqual(sut.layout, .tab)
        sut.layout = .accordion
        XCTAssertEqual(sut.layout, .accordion)
    }

    func testShowsApplePayAsPrimaryButton_CanBeChanged() {
        XCTAssertTrue(sut.showsApplePayAsPrimaryButton)
        sut.applePayButtonConfiguration.showsAsPrimaryButton = false
        XCTAssertFalse(sut.showsApplePayAsPrimaryButton)
    }

    func testApplePayButtonConfiguration_DefaultButtonType_IsNil() {
        XCTAssertNil(sut.applePayButtonConfiguration.buttonType)
    }

    func testApplePayButtonConfiguration_CanSetButtonType() {
        sut.applePayButtonConfiguration.buttonType = .checkout
        XCTAssertEqual(sut.applePayButtonConfiguration.buttonType, .checkout)
    }

    func testCheckoutButtonConfiguration_DefaultTitle_IsNil() {
        XCTAssertNil(sut.checkoutButtonConfiguration.title)
    }

    func testCheckoutButtonConfiguration_CanSetCustomTitle() {
        sut.checkoutButtonConfiguration.title = "Subscribe"
        XCTAssertEqual(sut.checkoutButtonConfiguration.title, "Subscribe")
    }

    func testCurrentPaymentMethod_CanBeSet() {
        XCTAssertNil(sut.currentPaymentMethod)
        sut.currentPaymentMethod = "card"
        XCTAssertEqual(sut.currentPaymentMethod, "card")
    }

    func testImageLoader_IsLazilyCreated() {
        let loader1 = sut.imageLoader
        let loader2 = sut.imageLoader
        XCTAssertTrue(loader1 === loader2)
    }

    func testPaymentSessionHandlerFactory_DefaultIsDefaultFactory() {
        XCTAssertTrue(sut.paymentSessionHandlerFactory is DefaultPaymentSessionHandlerFactory)
    }

    func testPaymentSessionHandlerFactory_CanBeReplaced() {
        let mockFactory = MockPaymentSessionHandlerFactory()
        sut.paymentSessionHandlerFactory = mockFactory
        XCTAssertTrue(sut.paymentSessionHandlerFactory is MockPaymentSessionHandlerFactory)
    }

    // MARK: - completePaymentSession

    func testCompletePaymentSession_WithNoDismissAction_CompletesImmediately() async {
        sut.dismissAction = nil
        await sut.completePaymentSession()
        // Should complete without hanging
    }

    func testCompletePaymentSession_WithDismissAction_CallsDismissAndCompletes() async {
        var dismissCalled = false
        sut.dismissAction = { completion in
            dismissCalled = true
            completion()
        }
        await sut.completePaymentSession()
        XCTAssertTrue(dismissCalled)
    }

    func testCompletePaymentSession_ClearsDismissActionAfterCall() async {
        sut.dismissAction = { completion in
            completion()
        }
        XCTAssertNotNil(sut.dismissAction)
        await sut.completePaymentSession()
        XCTAssertNil(sut.dismissAction)
    }

    func testCompletePaymentSession_DismissAction_WaitsForCompletion() async {
        var completionCalled = false
        sut.dismissAction = { completion in
            // Simulate async dismissal
            DispatchQueue.main.async {
                completionCalled = true
                completion()
            }
        }
        await sut.completePaymentSession()
        XCTAssertTrue(completionCalled)
    }

    // MARK: - hasPaymentUI

    func testHasPaymentUI_AlwaysTrue() {
        XCTAssertTrue(sut.hasPaymentUI)
    }
}

// MARK: - PaymentSectionController Protocol Tests

@MainActor
class PaymentSectionControllerProtocolTests: BasePaymentSectionControllerTests {

    override func setUp() {
        super.setUp()
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        methodType.cardSchemes = AWXCardScheme.allAvailable
        mockMethodProvider.methods = [methodType]
        mockMethodProvider.selectedMethod = methodType
        mockSectionProvider.preferConsentPayment = false
    }

    func testPrepareForEmbeddedCheckout_NonEmbedded_DoesNothing() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        sectionController.prepareForEmbeddedCheckout(
            paymentMethod: "card",
            handler: mockFactory.mockHandler
        )

        // Non-embedded: should not modify handler or set currentPaymentMethod
        XCTAssertTrue(mockFactory.mockHandler.showIndicator)
        XCTAssertNil(mockSectionProvider.paymentUIContext.currentPaymentMethod)
    }

    func testPrepareForEmbeddedCheckout_Embedded_SetsPaymentMethodAndDisablesIndicator() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockSectionProvider.simulateEmbeddedMode()
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        sectionController.prepareForEmbeddedCheckout(
            paymentMethod: "card",
            handler: mockFactory.mockHandler
        )

        XCTAssertEqual(mockSectionProvider.paymentUIContext.currentPaymentMethod, "card")
        XCTAssertFalse(mockFactory.mockHandler.showIndicator)
    }

    func testPrepareForEmbeddedCheckout_Embedded_NilHandler() {
        mockSectionProvider.simulateEmbeddedMode()
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        // Should not crash when handler is nil
        sectionController.prepareForEmbeddedCheckout(
            paymentMethod: "card",
            handler: nil
        )

        XCTAssertEqual(mockSectionProvider.paymentUIContext.currentPaymentMethod, "card")
    }

    func testPrepareForEmbeddedCheckout_Embedded_WithProcessingStateDelegate() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        let processingDelegate = MockProcessingStateDelegate()
        mockSectionProvider.simulateEmbeddedMode(delegate: processingDelegate)
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        sectionController.prepareForEmbeddedCheckout(
            paymentMethod: "card",
            handler: mockFactory.mockHandler
        )

        // Delegate implements processing state callback, so it should be called
        XCTAssertTrue(processingDelegate.processingStateChangedCalled)
        XCTAssertEqual(processingDelegate.processingStatePaymentMethod, "card")
        XCTAssertEqual(processingDelegate.processingStateIsProcessing, true)
    }

    // MARK: - checkoutButtonTitle

    func testCheckoutButtonTitle_OneOffSession_DefaultsPay() {
        // Default mock session is one-off with amount > 0 (shouldShowPayAsCta == true)
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        XCTAssertEqual(sectionController.checkoutButtonTitle, "Pay")
    }

    func testCheckoutButtonTitle_RecurringSession_DefaultsConfirm() {
        let session = AWXRecurringSession()
        session.countryCode = "AU"
        session.setCustomerId("customer_id")
        mockMethodProvider.session = session
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        XCTAssertEqual(sectionController.checkoutButtonTitle, "Confirm")
    }

    func testCheckoutButtonTitle_CustomTitle_OverridesDefault() {
        mockMethodProvider.session.requiredBillingContactFields = []
        mockSectionProvider.paymentUIContext.checkoutButtonConfiguration.title = "Subscribe"
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        XCTAssertEqual(sectionController.checkoutButtonTitle, "Subscribe")
    }

    func testCheckoutButtonTitle_CustomTitle_OverridesRecurringDefault() {
        let session = AWXRecurringSession()
        session.countryCode = "AU"
        session.setCustomerId("customer_id")
        mockMethodProvider.session = session
        mockMethodProvider.session.requiredBillingContactFields = []
        mockSectionProvider.paymentUIContext.checkoutButtonConfiguration.title = "Donate"
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let sectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            XCTFail()
            return
        }

        XCTAssertEqual(sectionController.checkoutButtonTitle, "Donate")
    }
}
