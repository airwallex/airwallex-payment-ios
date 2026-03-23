//
//  ApplePaySectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPaymentSheet
import PassKit
import UIKit
import XCTest

@MainActor class ApplePaySectionControllerTests: BasePaymentSectionControllerTests {
    
    override func setUp() {
        super.setUp()
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey
        mockMethodProvider.methods = [applePayMethod]
    }
    
    func testInit() {
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()
        
        XCTAssertEqual([PaymentSectionType.applePay], mockManager.sections)
        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let sectionItems = [controller.sectionItem(.applePayButton)]
        XCTAssertEqual(sectionItems, mockManager.diffableDataSource.snapshot().itemIdentifiers)
        XCTAssertEqual(controller.section, PaymentSectionType.applePay)
        XCTAssertEqual(controller.items, [.applePayButton])
    }
    
    func testSupplementaryView() {
        let mockCardMethod = AWXPaymentMethodType()
        mockCardMethod.name = AWXCardKey
        mockMethodProvider.methods.append(mockCardMethod)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let sectionItem = controller.sectionItem(.applePayButton)
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: sectionItem) else {
            XCTFail()
            return
        }
        guard controller.context.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: indexPath
        ) != nil else {
            XCTFail()
            return
        }
    }

    func testAccordionLayout_Items() {
        mockSectionProvider.layout = .accordion
        mockSectionProvider.simulateEmbeddedMode()
        mockSectionProvider.paymentUIContext.applePayButtonConfiguration.showsAsPrimaryButton = false  // Apple Pay integrated in accordion
        mockMethodProvider.selectedMethod = mockMethodProvider.methods.first
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        XCTAssertEqual(controller.items, [.accordionKey, .applePayReminder, .applePayButton])
    }

    func testAccordionLayout_Cells() {
        mockSectionProvider.layout = .accordion
        mockSectionProvider.simulateEmbeddedMode()
        mockSectionProvider.paymentUIContext.applePayButtonConfiguration.showsAsPrimaryButton = false  // Apple Pay integrated in accordion
        mockMethodProvider.selectedMethod = mockMethodProvider.methods.first
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        let snapshot = mockManager.diffableDataSource.snapshot()
        let expectedItems = [
            controller.sectionItem(.accordionKey),
            controller.sectionItem(.applePayReminder),
            controller.sectionItem(.applePayButton)
        ]
        XCTAssertEqual(expectedItems, snapshot.itemIdentifiers)
    }

    // MARK: - Tests for enableAccordionLayout behavior

    func testAccordionLayout_WhenNotEmbedded_UsesTabLayout() {
        // Accordion layout should only apply when BOTH isEmbedded == true AND layout == .accordion
        // When layout is .accordion but isEmbedded is false, it should use tab layout (just button)
        mockSectionProvider.layout = .accordion
        mockMethodProvider.selectedMethod = mockMethodProvider.methods.first
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        // Should use tab layout items (just the button) when not embedded
        XCTAssertEqual(controller.items, [.applePayButton])
    }

    func testTabLayout_WhenEmbedded_UsesTabLayout() {
        // When layout is .tab, it should use tab layout regardless of isEmbedded
        mockSectionProvider.layout = .tab
        mockSectionProvider.simulateEmbeddedMode()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        // Should use tab layout items (just the button)
        XCTAssertEqual(controller.items, [.applePayButton])
    }

    func testTabLayout_WhenNotEmbedded_UsesTabLayout() {
        // Default behavior: tab layout + not embedded should use tab layout
        mockSectionProvider.layout = .tab
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        // Should use tab layout items (just the button)
        XCTAssertEqual(controller.items, [.applePayButton])
    }

    func testTabLayout_WhenShowsApplePayAsPrimaryButtonFalse_ShowsReminderAndButton() {
        // When showsApplePayAsPrimaryButton is false and layout is tab,
        // Apple Pay is selected from the tab list and should show reminder + button
        mockSectionProvider.layout = .tab
        mockSectionProvider.simulateEmbeddedMode()
        mockSectionProvider.paymentUIContext.applePayButtonConfiguration.showsAsPrimaryButton = false
        mockMethodProvider.selectedMethod = mockMethodProvider.methods.first
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        // Tab layout type should show reminder + button (no accordion key)
        XCTAssertEqual(controller.items, [.applePayReminder, .applePayButton])
    }

    // MARK: - Custom Button Type Tests

    func testCustomButtonType_UsedWhenSet() {
        mockSectionProvider.paymentUIContext.applePayButtonConfiguration.buttonType = .buy
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let sectionItem = controller.sectionItem(.applePayButton)
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: sectionItem),
              let cell = mockManager.collectionView.cellForItem(at: indexPath) as? ApplePayCell else {
            XCTFail("apple pay cell not found")
            return
        }
        XCTAssertEqual(cell.viewModel?.buttonType, .buy)
    }

    func testDefaultButtonType_PlainForOneOff() {
        // Default session is one-off (shouldShowPayAsCta = true)
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let sectionItem = controller.sectionItem(.applePayButton)
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: sectionItem),
              let cell = mockManager.collectionView.cellForItem(at: indexPath) as? ApplePayCell else {
            XCTFail("apple pay cell not found")
            return
        }
        XCTAssertEqual(cell.viewModel?.buttonType, .plain)
    }

    func testDefaultButtonType_SubscribeForRecurring() {
        // Use a recurring session where shouldShowPayAsCta is false
        let recurringSession = AWXRecurringSession()
        recurringSession.countryCode = "AU"
        recurringSession.setCustomerId("customer_id")
        mockMethodProvider.session = recurringSession
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }
        let sectionItem = controller.sectionItem(.applePayButton)
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: sectionItem),
              let cell = mockManager.collectionView.cellForItem(at: indexPath) as? ApplePayCell else {
            XCTFail("apple pay cell not found")
            return
        }
        XCTAssertEqual(cell.viewModel?.buttonType, .subscribe)
    }

    // MARK: - Checkout Tests

    func testCheckout_CallsConfirmApplePay() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay],
              let applePayController = controller.embededSectionController as? ApplePaySectionController else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        applePayController.checkout()

        XCTAssertTrue(mockFactory.createHandlerCalled)
        XCTAssertTrue(mockFactory.mockHandler.confirmApplePayCalled)
        XCTAssertEqual(mockFactory.mockHandler.confirmApplePayCancelOnDismiss, false)
    }

    func testCheckout_Embedded_CallsConfirmApplePayWithCancelOnDismissTrue() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockSectionProvider.simulateEmbeddedMode()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay],
              let applePayController = controller.embededSectionController as? ApplePaySectionController else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        applePayController.checkout()

        XCTAssertTrue(mockFactory.mockHandler.confirmApplePayCalled)
        XCTAssertEqual(mockFactory.mockHandler.confirmApplePayCancelOnDismiss, true)
    }

    func testCheckout_Embedded_SetsShowIndicatorFalse() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockSectionProvider.simulateEmbeddedMode()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay],
              let applePayController = controller.embededSectionController as? ApplePaySectionController else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        applePayController.checkout()

        XCTAssertFalse(mockFactory.mockHandler.showIndicator)
    }

    func testCheckout_NonEmbedded_KeepsShowIndicatorTrue() {
        let mockFactory = mockSectionProvider.configureMockHandlerFactory()
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay],
              let applePayController = controller.embededSectionController as? ApplePaySectionController else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        applePayController.checkout()

        XCTAssertTrue(mockFactory.mockHandler.showIndicator)
    }
}

// MARK: - Item Identifiers (mirroring ApplePaySectionController)
private extension String {
    static let accordionKey = "accordionKey"
    static let applePayReminder = "applePayReminder"
    static let applePayButton = "applePayButton"
}
