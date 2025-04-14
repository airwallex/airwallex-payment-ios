//
//  NewCardPaymentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class NewCardPaymentSectionControllerTests: BasePaymentSectionControllerTests {
    
    override func setUp() {
        super.setUp()
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        mockMethodProvider.methods = [methodType]
        mockMethodProvider.selectedMethod = methodType
        
        guard let data = Bundle.dataOfFile("payment_consents"),
              let response = AWXGetPaymentConsentsResponse.parse(data) as? AWXGetPaymentConsentsResponse,
              response.items.count == 2 else {
            XCTFail()
            return
        }
        mockMethodProvider.consents = response.items
        mockSectionProvider.preferConsentPayment = false
    }
    
    private func getCardSectionController() -> NewCardPaymentSectionController? {
        guard let anySectionController = mockManager.sectionControllers[.cardPaymentNew],
              let cardSectionController = anySectionController.embededSectionController as? NewCardPaymentSectionController else {
            return nil
        }
        return cardSectionController
    }
    
    func testInit() {
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentNew)
        XCTAssertFalse(sectionController.items.isEmpty)
        XCTAssertTrue(sectionController.items.contains(NewCardPaymentSectionController.Item.consentToggle.rawValue))
        mockMethodProvider.consents = []
        mockManager.performUpdates()
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.consentToggle.rawValue))
    }
    
    func testInitWithAccordion() {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentNew)
        mockViewController.view.layoutIfNeeded()
        XCTAssertNotNil(sectionController.context.cellForItem(NewCardPaymentSectionController.Item.accordionKey.rawValue))
    }
    
    func testRequiredBillingFields_None() {
        mockMethodProvider.session.requiredBillingContactFields = []
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.cardholderName.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldEmail.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldPhone.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldAddress.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldCountryCode.rawValue))
    }
    
    func testRequiredBillingFields_AddressAndCountryCode() {
        mockMethodProvider.session.requiredBillingContactFields = [.name, .address, .countryCode]
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertTrue(sectionController.items.contains(NewCardPaymentSectionController.Item.cardholderName.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldEmail.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldPhone.rawValue))
        XCTAssertTrue(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldAddress.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldCountryCode.rawValue))
    }
    
    func testRequiredBillingFields_EmailAndPhone() {
        mockMethodProvider.session.requiredBillingContactFields = [.phone, .email, .countryCode]
        mockManager.performUpdates()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.cardholderName.rawValue))
        XCTAssertTrue(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldEmail.rawValue))
        XCTAssertTrue(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldPhone.rawValue))
        XCTAssertFalse(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldAddress.rawValue))
        XCTAssertTrue(sectionController.items.contains(NewCardPaymentSectionController.Item.billingFieldCountryCode.rawValue))
    }
    
    func testSaveCardToggle_OneOff() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.customerId = "customer_id"
        session.requiredBillingContactFields = []
        mockMethodProvider.session = session
        
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let itemIdentifier = NewCardPaymentSectionController.Item.saveCardToggle.rawValue
        XCTAssertTrue(sectionController.items.contains(itemIdentifier))

        guard let cell = sectionController.context.cellForItem(itemIdentifier) as? CheckBoxCell,
              let isSelected = cell.viewModel?.isSelected else {
            XCTFail()
            return
        }
        XCTAssertEqual(isSelected, session.autoSaveCardForFuturePayments)
    }
    
    func testSaveCardToggle_OneOff_noCustomerId() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.requiredBillingContactFields = []
        mockMethodProvider.session = session
        
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let itemIdentifier = NewCardPaymentSectionController.Item.saveCardToggle.rawValue
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        XCTAssertNil(sectionController.context.cellForItem(itemIdentifier))
    }
    
    func testSaveCardToggle_OneOff_disableAutoSave() {
        let session = AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.customerId = "customer_id"
        session.requiredBillingContactFields = []
        session.autoSaveCardForFuturePayments = false
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let itemIdentifier = NewCardPaymentSectionController.Item.saveCardToggle.rawValue
        XCTAssertTrue(sectionController.items.contains(itemIdentifier))

        guard let cell = sectionController.context.cellForItem(itemIdentifier) as? CheckBoxCell,
              let isSelected = cell.viewModel?.isSelected else {
            XCTFail()
            return
        }
        XCTAssertEqual(isSelected, session.autoSaveCardForFuturePayments)
    }
    
    func testSaveCardToggle_RecurringSession() {
        let session = AWXRecurringSession()
        session.setCustomerId("customer_id")
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let itemIdentifier = NewCardPaymentSectionController.Item.saveCardToggle.rawValue
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        XCTAssertNil(sectionController.context.cellForItem(itemIdentifier))
    }
    
    func testSaveCardToggle_RecurringWithIntentSession() {
        let session = AWXRecurringWithIntentSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.id = "intent_id"
        session.paymentIntent?.clientSecret = "client_secret"
        session.paymentIntent?.customerId = "customer_id"
        mockMethodProvider.session = session
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let itemIdentifier = NewCardPaymentSectionController.Item.saveCardToggle.rawValue
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        XCTAssertNil(sectionController.context.cellForItem(itemIdentifier))
    }
    
    func testSaveCardToggle_toggleUnionPay() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let itemIdentifier = NewCardPaymentSectionController.Item.saveCardToggle.rawValue
        XCTAssertFalse(sectionController.items.contains(itemIdentifier))
        guard let cell = sectionController.context.cellForItem(itemIdentifier) as? CheckBoxCell else {
            XCTFail()
            return
        }
        XCTAssert(cell.viewModel?.isSelected == true)
        cell.viewModel?.toggleSelection()
        XCTAssert(cell.viewModel?.isSelected == false)
//        sectionController.
    }
    
    func testReuseShippingInfo_All() {
        mockMethodProvider.session.requiredBillingContactFields = [.address, .email, .name, .phone,]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let addressItem = NewCardPaymentSectionController.Item.billingFieldAddress.rawValue
        guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReuseShippingAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReuseShippingAddress == true)
        XCTAssertEqual(addressCell.viewModel?.countryConfigurer.country?.countryCode, mockShippingInfo.address?.countryCode)
        XCTAssertEqual(addressCell.viewModel?.stateConfigurer.text, mockShippingInfo.address?.state)
        XCTAssertEqual(addressCell.viewModel?.cityConfigurer.text, mockShippingInfo.address?.city)
        XCTAssertEqual(addressCell.viewModel?.zipConfigurer.text, mockShippingInfo.address?.postcode)
        
        let emailItem = NewCardPaymentSectionController.Item.billingFieldEmail.rawValue
        guard let emailCell = sectionController.context.cellForItem(emailItem) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(emailCell.viewModel?.text, mockShippingInfo.email)
        
        
        let nameItem = NewCardPaymentSectionController.Item.cardholderName.rawValue
        guard let nameCell = sectionController.context.cellForItem(nameItem) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(nameCell.viewModel?.text, mockShippingInfo.fullName)
        
        let phoneItem = NewCardPaymentSectionController.Item.billingFieldPhone.rawValue
        guard let phoneCell = sectionController.context.cellForItem(phoneItem) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(phoneCell.viewModel?.text, mockShippingInfo.phoneNumber)
    }
    
    func testReuseShippingInfo_RequireCountryCode() {
        mockMethodProvider.session.requiredBillingContactFields = [.countryCode]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let addressItem = NewCardPaymentSectionController.Item.billingFieldAddress.rawValue
        XCTAssertNil(sectionController.context.cellForItem(addressItem))
        
        let countryCodeItem = NewCardPaymentSectionController.Item.billingFieldCountryCode.rawValue
        guard let countryCell = sectionController.context.cellForItem(countryCodeItem) as? CountrySelectionCell else {
            XCTFail()
            return
        }
        XCTAssertEqual(countryCell.viewModel?.country?.countryCode, mockShippingInfo.address?.countryCode)
    }
    
    func testReuseShippingInfo_IncompleteAddress() {
        mockMethodProvider.session.requiredBillingContactFields = [.address]
        mockShippingInfo.address?.postcode = nil
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let addressItem = NewCardPaymentSectionController.Item.billingFieldAddress.rawValue
        guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReuseShippingAddress == false)
        XCTAssert(addressCell.viewModel?.shouldReuseShippingAddress == false)
        // can not fully reuse incomplete address info - the reuse toggle is invisible
        // but will still prefill with shipping info
        XCTAssertEqual(addressCell.viewModel?.countryConfigurer.country?.countryCode, mockShippingInfo.address?.countryCode)
        XCTAssertEqual(addressCell.viewModel?.stateConfigurer.text, mockShippingInfo.address?.state)
        XCTAssertEqual(addressCell.viewModel?.cityConfigurer.text, mockShippingInfo.address?.city)
        XCTAssertEqual(addressCell.viewModel?.zipConfigurer.text, mockShippingInfo.address?.postcode)
    }
    
    func testReuseShippingInfo_ReuseToggle() {
        mockMethodProvider.session.requiredBillingContactFields = [.address]
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        guard let sectionController = getCardSectionController() else { XCTFail(); return }
        let addressItem = NewCardPaymentSectionController.Item.billingFieldAddress.rawValue
        guard let addressCell = sectionController.context.cellForItem(addressItem) as? BillingInfoCell else {
            XCTFail()
            return
        }
        XCTAssert(addressCell.viewModel?.canReuseShippingAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReuseShippingAddress == true)
        
        addressCell.viewModel?.toggleReuseSelection()
        mockViewController.view.layoutIfNeeded()
        XCTAssert(addressCell.viewModel?.canReuseShippingAddress == true)
        XCTAssert(addressCell.viewModel?.shouldReuseShippingAddress == false)
    }
    
}
