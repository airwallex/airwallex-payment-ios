//
//  SchemaPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/15.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class SchemaPaymentSectionControllerTests: BasePaymentSectionControllerTests {

    var mockSchemaMethod: AWXPaymentMethodType!
    override func setUp() {
        super.setUp()
        
        mockSchemaMethod = AWXPaymentMethodType()
        mockSchemaMethod.name = "online_banking"
        mockSchemaMethod.displayName = "Online Banking"
        mockSchemaMethod.resources = AWXResources()
        mockSchemaMethod.resources.hasSchema = true
        
        let mockOnlineBankingData = Bundle.dataOfFile("method_type_online_banking")!
        let mockSchemaDetails = AWXGetPaymentMethodTypeResponse.parse(mockOnlineBankingData) as! AWXGetPaymentMethodTypeResponse
        mockMethodProvider.mockSchemaDetails = mockSchemaDetails
        
        MockURLProtocol.mockResponse = (
            Bundle.dataOfFile("bank_list")!,
            HTTPURLResponse(
                url: URL(string: "https://api-demo.airwallex.com")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ),
            nil
        )
        
        mockMethodProvider.methods = [mockSchemaMethod]
        mockMethodProvider.selectedMethod = mockSchemaMethod
    }
    
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.resetMockResponses()
    }
    
    private func getSchemaPaymentSectionController() -> SchemaPaymentSectionController? {
        guard let sectionController = mockManager.sectionControllers[.schemaPayment("online_banking")]?.embededSectionController as? SchemaPaymentSectionController else {
            XCTFail()
            return nil
        }
        return sectionController
    }
    
    func testInit() async {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        XCTAssertEqual(sectionController.section, .schemaPayment("online_banking"))
        XCTAssertEqual(sectionController.paymentUIContext.layout, .tab)
        try? await Task.sleep(nanoseconds: 500_000_000)
        XCTAssert(sectionController.items.contains("shopper_name"))
        XCTAssert(sectionController.items.contains("shopper_email"))
        XCTAssert(sectionController.items.contains("shopper_phone"))
        XCTAssert(sectionController.items.contains(.bankName))
        XCTAssertFalse(sectionController.items.contains(.accordionKey))
    }
    
    func testInit_Accordionlayout() async {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        XCTAssertEqual(sectionController.section, .schemaPayment("online_banking"))
        XCTAssertEqual(sectionController.paymentUIContext.layout, .accordion)
        try? await Task.sleep(nanoseconds: 100_000)
        XCTAssert(sectionController.items.contains(.accordionKey))
        mockViewController.view.layoutIfNeeded()
        guard let cell = sectionController.context.cellForItem(sectionController.sectionItem(.accordionKey)) as? AccordionPaymentMethodCell else {
            XCTFail()
            return
        }
        XCTAssert(cell.viewModel?.isSelected == true)
    }
    
    func testPrefillStatus() async {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 1000_000_000)
        mockViewController.view.layoutIfNeeded()
        // check shopper name prefill
        guard let nameCell = sectionController.context.cellForItem(sectionController.sectionItem("shopper_name")) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockMethodProvider.session.billing?.fullName)
        // check email prefill
        guard let emailCell = sectionController.context.cellForItem(sectionController.sectionItem("shopper_email")) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(emailCell.viewModel?.text, mockMethodProvider.session.billing?.email)
        // check phone number prefill
        guard let phoneNumberCell = sectionController.context.cellForItem(sectionController.sectionItem("shopper_phone")) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(phoneNumberCell.viewModel?.text, mockMethodProvider.session.billing?.phoneNumber)
        
        // check bank selection prefill
        guard let bankCell = sectionController.context.cellForItem(sectionController.sectionItem(.bankName)) as? BankSelectionCell else {
            XCTFail()
            return
        }
        XCTAssertNotNil(bankCell.viewModel?.bank)
    }
    
    func testBankSelectionValidation() async {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 1000_000_000)
        mockViewController.view.layoutIfNeeded()

        guard let bankCell = sectionController.context.cellForItem(sectionController.sectionItem(.bankName)) as? BankSelectionCell else {
            XCTFail()
            return
        }
        XCTAssertNotNil(bankCell.viewModel?.bank)
        bankCell.viewModel?.handleUserInteraction()

        // checkout validation
        XCTAssertNil(bankCell.viewModel?.errorHint)
        bankCell.viewModel?.bank = nil
        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        checkoutCell.viewModel?.checkoutAction()
        XCTAssertNotNil(bankCell.viewModel?.errorHint)
    }
    
    func testUIFieldValidation() async {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 1000_000_000)
        mockViewController.view.layoutIfNeeded()
        // check shopper name prefill
        guard let nameCell = sectionController.context.cellForItem(sectionController.sectionItem("shopper_name")) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockMethodProvider.session.billing?.fullName)
        
        // checkout validation
        XCTAssertNil(nameCell.viewModel?.errorHint)
        nameCell.viewModel?.text = nil
        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        checkoutCell.viewModel?.checkoutAction()
        XCTAssertNotNil(nameCell.viewModel?.errorHint)
    }

    // MARK: - Checkout Tests

    func testCheckout_ValidInputs_CallsConfirmRedirectPayment() async {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 500_000_000)
        mockViewController.view.layoutIfNeeded()

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockFactory.createHandlerCalled)
        XCTAssertTrue(mockFactory.mockHandler.confirmRedirectPaymentCalled)
        XCTAssertEqual(mockFactory.mockHandler.confirmRedirectPaymentMethod?.type, "online_banking")
    }

    func testCheckout_Embedded_SetsShowIndicatorFalse() async {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockSectionProvider.simulateEmbeddedMode()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 500_000_000)
        mockViewController.view.layoutIfNeeded()

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(mockFactory.mockHandler.showIndicator)
    }

    func testCheckout_Embedded_InvalidInput_NotifiesDelegateOfValidationFailure() async {
        let mockDelegate = MockValidationFailureDelegate()
        mockSectionProvider.simulateEmbeddedMode(delegate: mockDelegate)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 500_000_000)
        mockViewController.view.layoutIfNeeded()

        // Clear a required field to trigger validation failure
        guard let nameCell = sectionController.context.cellForItem(sectionController.sectionItem("shopper_name")) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        nameCell.viewModel?.text = nil

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockDelegate.validationFailedCalled)
        XCTAssertNotNil(mockDelegate.validationFailedView)
    }

    func testCheckout_NonEmbedded_KeepsShowIndicatorTrue() async {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 500_000_000)
        mockViewController.view.layoutIfNeeded()

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(mockFactory.mockHandler.showIndicator)
    }
}

// MARK: - Item Identifiers (mirroring SchemaPaymentSectionController)
private extension String {
    static let accordionKey = "accordionKey"
    static let bankName = "bankName"
    static let redirectReminder = "redirectReminder"
    static let checkoutButton = "checkoutButton"
}
