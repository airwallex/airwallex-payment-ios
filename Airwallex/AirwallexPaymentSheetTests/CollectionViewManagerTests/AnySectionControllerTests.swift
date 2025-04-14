//
//  AnySectionControllerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class AnySectionControllerTests: XCTestCase {
    var mockContext: MockCollectionViewContext!
    var mockSectionController: MockSectionController<String, String>!
    
    @MainActor override func setUp() {
        super.setUp()
        mockContext = MockCollectionViewContext()
        mockSectionController = MockSectionController(section: "TestSection", items: ["Item1", "Item2"])
    }

    @MainActor func testSectionControllerProtocolMethods() {
        let anySectionController = mockSectionController.anySectionController()
        anySectionController.bind(context: mockContext)
        
        XCTAssert(mockSectionController === anySectionController.embededSectionController)
        
        XCTAssertEqual(anySectionController.section, "TestSection")
        XCTAssertEqual(anySectionController.items, ["Item1", "Item2"])
        XCTAssert(anySectionController.context === mockSectionController.context)
        
        // Test updateItemsIfNecessary
        anySectionController.updateItemsIfNecessary()
        XCTAssertTrue(mockSectionController.updateItemsIfNecessaryCalled)

        // Test cell(for:at:)
        let indexPath = IndexPath(item: 0, section: 0)
        XCTAssertNotNil(anySectionController.cell(for: "Item1", at: indexPath))
        XCTAssertEqual(mockSectionController.cellForItemAtIndexPathCalled?.0, "Item1")
        XCTAssertEqual(mockSectionController.cellForItemAtIndexPathCalled?.1, indexPath)

        // Test supplementaryView(for:at:)
        _ = anySectionController.supplementaryView(for: "Header", at: indexPath)
        XCTAssertEqual(mockSectionController.supplementaryViewForElementKindAtIndexPathCalled?.0, "Header")
        XCTAssertEqual(mockSectionController.supplementaryViewForElementKindAtIndexPathCalled?.1, indexPath)

        // Test collectionView(didSelectItem:at:)
        anySectionController.collectionView(didSelectItem: "Item1", at: indexPath)
        XCTAssertEqual(mockSectionController.didSelectItemCalled?.0, "Item1")
        XCTAssertEqual(mockSectionController.didSelectItemCalled?.1, indexPath)

        // Test willDisplay(cell:itemIdentifier:at:)
        let mockCell = UICollectionViewCell()
        anySectionController.willDisplay(cell: mockCell, itemIdentifier: "Item1", at: indexPath)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.0, mockCell)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.1, "Item1")
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.2, indexPath)

        // Test didEndDisplaying(cell:itemIdentifier:at:)
        anySectionController.didEndDisplaying(cell: mockCell, itemIdentifier: "Item1", at: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.0, mockCell)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.1, "Item1")
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.2, indexPath)

        // Test willDisplay(supplementaryView:at:)
        let mockSupplementaryView = UICollectionReusableView()
        anySectionController.willDisplay(supplementaryView: mockSupplementaryView, at: indexPath)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.0, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.1, indexPath)

        // Test didEndDisplaying(supplementaryView:at:)
        anySectionController.didEndDisplaying(supplementaryView: mockSupplementaryView, at: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.0, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.1, indexPath)

        // Test sectionWillDisplay
        anySectionController.sectionWillDisplay()
        XCTAssertTrue(mockSectionController.sectionDisplaying)

        // Test sectionDidEndDisplaying
        anySectionController.sectionDidEndDisplaying()
        XCTAssertFalse(mockSectionController.sectionDisplaying)
    }
}
