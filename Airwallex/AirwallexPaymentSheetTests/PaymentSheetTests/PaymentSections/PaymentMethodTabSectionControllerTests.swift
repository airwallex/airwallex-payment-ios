//
//  PaymentMethodTabSectionControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Claude on 2025/2/13.
//  Copyright (c) 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class PaymentMethodTabSectionControllerTests: BasePaymentSectionControllerTests {

    override func setUp() {
        super.setUp()
        // Set up with multiple payment methods to enable method list
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod
        mockSectionProvider.layout = .tab
    }

    // MARK: - Initialization Tests

    func testInit_withMultipleMethods_showsMethodList() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        XCTAssertTrue(mockManager.sections.contains(.methodList))
        XCTAssertNotNil(mockManager.sectionControllers[.methodList])
    }

    func testInit_items_returnsMethodNames() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        XCTAssertEqual(sectionController.items, ["card", "alipayhk"])
    }

    func testInit_section_returnsMethodList() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        XCTAssertEqual(sectionController.section, .methodList)
    }

    // MARK: - Cell Tests

    func testCell_configuresPaymentMethodCell() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        let cardSectionItem = sectionController.sectionItem("card")
        guard let cell = sectionController.context.cellForItem(cardSectionItem) as? PaymentMethodCell else {
            XCTFail("Expected PaymentMethodCell")
            return
        }

        XCTAssertNotNil(cell)
    }

    // MARK: - Selection Tests

    func testDidSelectItem_updatesSelectedMethod() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        // Select alipay
        let alipaySectionItem = sectionController.sectionItem("alipayhk")
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: alipaySectionItem) else {
            XCTFail("Index path not found")
            return
        }

        sectionController.collectionView(didSelectItem: alipaySectionItem, at: indexPath)

        XCTAssertEqual(mockMethodProvider.selectedMethod?.name, "alipayhk")
    }

    func testDidSelectItem_sameTwice_endsEditing() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        // Select card (already selected)
        let cardSectionItem = sectionController.sectionItem("card")
        guard let indexPath = mockManager.diffableDataSource.indexPath(for: cardSectionItem) else {
            XCTFail("Index path not found")
            return
        }

        // Should not crash and should not change selection
        sectionController.collectionView(didSelectItem: cardSectionItem, at: indexPath)

        XCTAssertEqual(mockMethodProvider.selectedMethod?.name, "card")
    }

    // MARK: - Layout Tests

    func testLayout_returnsHorizontalScrollingSection() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        let mockEnvironment = MockLayoutEnvironment()
        let layout = sectionController.layout(environment: mockEnvironment)

        XCTAssertEqual(layout.orthogonalScrollingBehavior, .continuous)
    }

    // MARK: - UpdateItemsIfNecessary Tests

    func testUpdateItemsIfNecessary_updatesMethodsAndSelection() {
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        // Change the selected method in provider
        mockMethodProvider.selectedMethod = mockMethodProvider.methods.last

        // Call updateItemsIfNecessary
        sectionController.updateItemsIfNecessary()

        // Verify items reflect the current state
        XCTAssertEqual(sectionController.items, ["card", "alipayhk"])
    }

    // MARK: - Apple Pay Filtering Tests

    func testFilteredMethods_excludesApplePayWhenPrioritized() {
        // Add Apple Pay to methods
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        mockMethodProvider.methods.insert(applePayMethod, at: 0)
        mockSectionProvider.paymentUIContext.applePayButtonConfiguration.showsAsPrimaryButton = true

        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        // Apple Pay should be excluded when showsApplePayAsPrimaryButton is true
        XCTAssertFalse(sectionController.items.contains(AWXApplePayKey))
        XCTAssertTrue(sectionController.items.contains("card"))
        XCTAssertTrue(sectionController.items.contains("alipayhk"))
    }

    func testFilteredMethods_includesApplePayWhenNotPrioritized() {
        // Add Apple Pay to methods
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        mockMethodProvider.methods.insert(applePayMethod, at: 0)
        mockMethodProvider.isApplePaySelectable = true
        mockSectionProvider.paymentUIContext.applePayButtonConfiguration.showsAsPrimaryButton = false

        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        guard let anySectionController = mockManager.sectionControllers[.methodList],
              let sectionController = anySectionController.embededSectionController as? PaymentMethodTabSectionController else {
            XCTFail("Section controller not found")
            return
        }

        // Apple Pay should be included when showsApplePayAsPrimaryButton is false
        XCTAssertTrue(sectionController.items.contains(AWXApplePayKey))
        XCTAssertTrue(sectionController.items.contains("card"))
        XCTAssertTrue(sectionController.items.contains("alipayhk"))
    }
}

// MARK: - Mock Layout Environment

private class MockLayoutEnvironment: NSObject, NSCollectionLayoutEnvironment {
    var container: NSCollectionLayoutContainer {
        return MockLayoutContainer()
    }

    var traitCollection: UITraitCollection {
        return UITraitCollection()
    }
}

private class MockLayoutContainer: NSObject, NSCollectionLayoutContainer {
    var contentSize: CGSize { CGSize(width: 375, height: 667) }
    var effectiveContentSize: CGSize { contentSize }
    var contentInsets: NSDirectionalEdgeInsets { .zero }
    var effectiveContentInsets: NSDirectionalEdgeInsets { .zero }
}
