//
//  ApplePaySectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPaymentSheet
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
        mockSectionProvider.paymentUIContext.isEmbedded = true
        mockSectionProvider.paymentUIContext.prioritizeApplePay = false  // Apple Pay integrated in accordion
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
        mockSectionProvider.paymentUIContext.isEmbedded = true
        mockSectionProvider.paymentUIContext.prioritizeApplePay = false  // Apple Pay integrated in accordion
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
        mockSectionProvider.paymentUIContext.isEmbedded = false
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
        mockSectionProvider.paymentUIContext.isEmbedded = true
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
        mockSectionProvider.paymentUIContext.isEmbedded = false
        mockManager.performUpdates()
        mockViewController.view.layoutIfNeeded()

        guard let controller = mockManager.sectionControllers[PaymentSectionType.applePay] else {
            XCTFail("apple pay section controller not initialized")
            return
        }

        // Should use tab layout items (just the button)
        XCTAssertEqual(controller.items, [.applePayButton])
    }
}

// MARK: - Item Identifiers (mirroring ApplePaySectionController)
private extension String {
    static let accordionKey = "accordionKey"
    static let applePayReminder = "redirectReminder"
    static let applePayButton = "applePayButton"
}
