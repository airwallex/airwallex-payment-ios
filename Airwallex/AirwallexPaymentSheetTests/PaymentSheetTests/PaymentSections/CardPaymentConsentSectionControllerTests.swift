//
//  CardPaymentConsentSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/14.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

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
        XCTAssertEqual(mockManager.sections, [.methodList, .cardPaymentConsent])
        XCTAssertEqual(sectionController.section, PaymentSectionType.cardPaymentConsent)
        XCTAssert(sectionController.items.contains(.selectedConsent))
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
        XCTAssertEqual(mockManager.sections, [.methodList, .cardPaymentConsent])
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
        XCTAssert(sectionController.items.contains(.accordionKey))
        
        sectionController.collectionView(didSelectItem: sectionController.sectionItem(firstConsentId), at: IndexPath())
        mockViewController.view.layoutIfNeeded()
        XCTAssertEqual(sectionController.mode, .consentPayment)
        XCTAssert(sectionController.items.contains(.accordionKey))
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
        
        let firstConsentSectionItem = sectionController.sectionItem(firstConsentId)
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: firstConsentSectionItem) else {
            XCTFail()
            return
        }
        sectionController.collectionView(didSelectItem: firstConsentSectionItem, at: indexPath)
        mockViewController.view.layoutIfNeeded()
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentPayment)
        
        guard let cell = sectionController.context.cellForItem(sectionController.sectionItem(.selectedConsent)) as? CardSelectedConsentCell else {
            XCTFail()
            return
        }
        cell.viewModel?.buttonAction()
        XCTAssertEqual(sectionController.mode, CardPaymentConsentSectionController.Mode.consentList)
        mockViewController.view.layoutIfNeeded()
        guard let cell = sectionController.context.cellForItem(sectionController.sectionItem(.addNewCardToggle)) as? CardPaymentToggleCell  else {
            XCTFail()
            return
        }
        mockSectionProvider.actionCalled = false
        cell.viewModel?.buttonAction()
        XCTAssertTrue(mockSectionProvider.actionCalled)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.methodList, .cardPaymentNew])
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
        
        // test checkout with invalid CVC shows inline error
        guard let cell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        // Get CVC field and verify inline error is shown on validation failure
        guard let cvcCell = sectionController.context.cellForItem(sectionController.sectionItem(.cvcField)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        cvcCell.viewModel?.text = nil
        cell.viewModel?.checkoutAction()
        // Validation failures now show inline errors instead of alerts
        XCTAssertNotNil(cvcCell.viewModel?.errorHint)
    }

    // MARK: - Checkout Tests

    func testCheckout_ValidCVC_CallsConfirmConsentPayment() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockMethodProvider.consents.removeLast()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }

        guard let cvcCell = sectionController.context.cellForItem(sectionController.sectionItem(.cvcField)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        cvcCell.viewModel?.text = "123"

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockFactory.createHandlerCalled)
        XCTAssertTrue(mockFactory.mockHandler.confirmConsentPaymentCalled)
        XCTAssertNotNil(mockFactory.mockHandler.confirmConsentPaymentConsent)
    }

    func testCheckout_Embedded_SetsShowIndicatorFalse() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockSectionProvider.simulateEmbeddedMode()
        mockMethodProvider.consents.removeLast()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }

        guard let cvcCell = sectionController.context.cellForItem(sectionController.sectionItem(.cvcField)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        cvcCell.viewModel?.text = "123"

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        XCTAssertFalse(mockFactory.mockHandler.showIndicator)
    }

    func testCheckout_NonEmbedded_KeepsShowIndicatorTrue() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockMethodProvider.consents.removeLast()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[PaymentSectionType.cardPaymentConsent],
              let sectionController = anySectionController.embededSectionController as? CardPaymentConsentSectionController else {
            XCTFail()
            return
        }

        guard let cvcCell = sectionController.context.cellForItem(sectionController.sectionItem(.cvcField)) as? InfoCollectorCell else {
            XCTFail()
            return
        }
        cvcCell.viewModel?.text = "123"

        guard let checkoutCell = sectionController.context.cellForItem(sectionController.sectionItem(.checkoutButton)) as? CheckoutButtonCell else {
            XCTFail()
            return
        }

        checkoutCell.viewModel?.checkoutAction()

        XCTAssertTrue(mockFactory.mockHandler.showIndicator)
    }
}

// MARK: - Item Identifiers (mirroring CardPaymentConsentSectionController)
private extension String {
    static let accordionKey = "accordionKey"
    static let addNewCardToggle = "addNewCardToggle"
    static let checkoutButton = "checkoutButton"
    static let cvcField = "cvcField"
    static let selectedConsent = "selectedConsent"
}
