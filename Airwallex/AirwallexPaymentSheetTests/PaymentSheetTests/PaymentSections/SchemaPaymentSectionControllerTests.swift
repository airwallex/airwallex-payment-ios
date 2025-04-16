//
//  SchemaPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/15.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
@testable @_spi(AWX) import AirwallexPayment
import AirwallexCore

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
        XCTAssertEqual(sectionController.layout, .tab)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssert(sectionController.items.contains("shopper_name"))
        XCTAssert(sectionController.items.contains("shopper_email"))
        XCTAssert(sectionController.items.contains("shopper_phone"))
        XCTAssert(sectionController.items.contains("bank_name"))
        XCTAssertFalse(sectionController.items.contains(SchemaPaymentSectionController.Item.accordionKey))
    }
    
    func testInit_Accordionlayout() async {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        XCTAssertEqual(sectionController.section, .schemaPayment("online_banking"))
        XCTAssertEqual(sectionController.layout, .accordion)
        try? await Task.sleep(nanoseconds: 100_000)
        XCTAssert(sectionController.items.contains(SchemaPaymentSectionController.Item.accordionKey))
        mockViewController.view.layoutIfNeeded()
        guard let cell = sectionController.context.cellForItem(SchemaPaymentSectionController.Item.accordionKey) as? AccordionPaymentMethodCell else {
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
        guard let nameCell = sectionController.context.cellForItem("shopper_name") as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockMethodProvider.session.billing?.fullName)
        // check email prefill
        guard let emailCell = sectionController.context.cellForItem("shopper_email") as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(emailCell.viewModel?.text, mockMethodProvider.session.billing?.email)
        // check phone number prefill
        guard let phoneNumberCell = sectionController.context.cellForItem("shopper_phone") as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(phoneNumberCell.viewModel?.text, mockMethodProvider.session.billing?.phoneNumber)
        
        // check bank selection prefill
        guard let bankCell = sectionController.context.cellForItem("bank_name") as? BankSelectionCell else {
            XCTFail()
            return
        }
        XCTAssertNotNil(bankCell.viewModel?.bank)
    }
    
    func testBankSelection() async {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getSchemaPaymentSectionController() else { return }
        try? await Task.sleep(nanoseconds: 1000_000_000)
        mockViewController.view.layoutIfNeeded()
        
        guard let bankCell = sectionController.context.cellForItem("bank_name") as? BankSelectionCell else {
            XCTFail()
            return
        }
        XCTAssertNotNil(bankCell.viewModel?.bank)
        bankCell.viewModel?.handleUserInteraction()
        XCTAssert(mockViewController.presentedViewControllerSpy is AWXPaymentFormViewController)
        
        // checkout validation
        XCTAssertNil(bankCell.viewModel?.errorHint)
        bankCell.viewModel?.bank = nil
        guard let checkoutCell = sectionController.context.cellForItem(SchemaPaymentSectionController.Item.checkoutButton) as? CheckoutButtonCell else {
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
        guard let nameCell = sectionController.context.cellForItem("shopper_name") as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockMethodProvider.session.billing?.fullName)
        
        // checkout validation
        XCTAssertNil(nameCell.viewModel?.errorHint)
        nameCell.viewModel?.text = nil
        guard let checkoutCell = sectionController.context.cellForItem(SchemaPaymentSectionController.Item.checkoutButton) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        checkoutCell.viewModel?.checkoutAction()
        XCTAssertNotNil(nameCell.viewModel?.errorHint)
    }
}
