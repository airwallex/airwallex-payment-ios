//
//  CardPaymentConsentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet
import AirwallexCore

class CardPaymentConsentSectionControllerTests: BasePaymentSectionControllerTests {
    
    private var firstConsentId: String {
        mockMethodProvider.consents.first?.id ?? ""
    }
    
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
        mockSectionProvider.preferConsentPayment = true
    }
    
    func testInitWithSingleConsent() {
        mockMethodProvider.consents.removeLast()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }
        XCTAssertEqual(mockManager.sections, [.cardPaymentConsent])
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentConsent)
        XCTAssert(sectionController.items.contains(firstConsentId))
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentPayment)
    }
    
    func testInitWithMultipleConsent() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }
        XCTAssertEqual(mockManager.sections, [.cardPaymentConsent])
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentConsent)
        XCTAssert(sectionController.items.contains(firstConsentId))
        XCTAssert(sectionController.items.contains(mockMethodProvider.consents.last?.id ?? ""))
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentList)
    }
    
    func testInitWithAccordionLayout() {
        mockSectionProvider.layout = .accordion
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }
        XCTAssertEqual(mockManager.sections, [.cardPaymentConsent])
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentConsent)
        XCTAssert(sectionController.items.contains(CardPaymentConsentSectionController.Items.accordionKey))
        
        sectionController.collectionView(didSelectItem: firstConsentId, at: IndexPath())
        mockViewController.view.layoutIfNeeded()
        XCTAssertEqual(sectionController.mode, .consentPayment)
        XCTAssert(sectionController.items.contains(CardPaymentConsentSectionController.Items.accordionKey))
    }
    
    func testToggleListAndPaymentMode() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentList)
        
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: firstConsentId) else {
            XCTFail()
            return
        }
        sectionController.collectionView(didSelectItem: firstConsentId, at: indexPath)
        mockViewController.view.layoutIfNeeded()
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentPayment)
        
        guard let cell = sectionController.context.cellForItem(firstConsentId) as? CardSelectedConsentCell else {
            XCTFail()
            return
        }
        cell.viewModel?.buttonAction()
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentList)
        mockViewController.view.layoutIfNeeded()
        guard let cell = sectionController.context.cellForItem(CardPaymentConsentSectionController.Items.addNewCardToggle) as? CardPaymentToggleCell  else {
            XCTFail()
            return
        }
        mockSectionProvider.actionCalled = false
        cell.viewModel?.buttonAction()
        XCTAssertTrue(mockSectionProvider.actionCalled)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [PaymentSectionType.cardPaymentNew])
        XCTAssertFalse(mockSectionProvider.preferConsentPayment)
    }
    
    func testCheckoutValidation() {
        mockMethodProvider.consents.removeLast()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
                  XCTFail()
                  return
              }
        
        // test checkout
        guard let cell = sectionController.context.cellForItem(CardPaymentConsentSectionController.Items.checkoutButton) as? CheckoutButtonCell else {
            XCTFail()
            return
        }
        cell.viewModel?.checkoutAction()
        guard mockViewController.presentedViewControllerSpy is AWXAlertController else {
            XCTFail("expect alert")
            return
        }
    }
    
    func testAlertForDelete() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
                  XCTFail()
                  return
              }
        
        
        guard let consentID = mockMethodProvider.consents.first?.id,
              let cell = sectionController.context.cellForItem(consentID) as? CardConsentCell else {
            XCTFail()
            return
        }
        cell.viewModel?.buttonAction()
        guard mockViewController.presentedViewControllerSpy is AWXAlertController else {
            XCTFail("expect alert")
            return
        }
    }
    
}
