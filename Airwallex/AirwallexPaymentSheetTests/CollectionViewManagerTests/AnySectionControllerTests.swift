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

@MainActor class AnySectionControllerTests: XCTestCase {
    var mockContext: MockCollectionViewContext!
    var mockSectionController: MockSectionController<String, String>!
    
    override func setUp() {
        super.setUp()
        mockContext = MockCollectionViewContext()
        mockSectionController = MockSectionController(section: "TestSection", items: [.item1, .item2])
    }
    
    func testSectionControllerProtocolMethods() {
        let anySectionController = mockSectionController.anySectionController()
        anySectionController.bind(context: mockContext)
        
        XCTAssert(mockSectionController === anySectionController.embededSectionController)
        
        XCTAssertEqual(anySectionController.section, "TestSection")
        XCTAssertEqual(anySectionController.items, [.item1, .item2])
        XCTAssert(anySectionController.context === mockSectionController.context)
        
        // Test updateItemsIfNecessary
        anySectionController.updateItemsIfNecessary()
        XCTAssertTrue(mockSectionController.updateItemsIfNecessaryCalled)
    
        // Test cell(for:at:)
        let indexPath = IndexPath(item: 0, section: 0)
        let sectionItem1 = CompoundItem("TestSection", String.item1)
        XCTAssertNotNil(anySectionController.cell(for: sectionItem1, at: indexPath))
        XCTAssertEqual(mockSectionController.cellForItemAtIndexPathCalled?.sectionItem, sectionItem1)
        XCTAssertEqual(mockSectionController.cellForItemAtIndexPathCalled?.indexPath, indexPath)
    
        // Test supplementaryView(for:at:)
        _ = anySectionController.supplementaryView(for: "Header", at: indexPath)
        XCTAssertEqual(mockSectionController.supplementaryViewForElementKindAtIndexPathCalled?.elementKind, "Header")
        XCTAssertEqual(mockSectionController.supplementaryViewForElementKindAtIndexPathCalled?.indexPath, indexPath)
    
        // Test collectionView(didSelectItem:at:)
        anySectionController.collectionView(didSelectItem: sectionItem1, at: indexPath)
        XCTAssertEqual(mockSectionController.didSelectItemCalled?.sectionItem, sectionItem1)
        XCTAssertEqual(mockSectionController.didSelectItemCalled?.indexPath, indexPath)
    
        // Test willDisplay(cell:sectionItem:at:)
        let mockCell = UICollectionViewCell()
        anySectionController.willDisplay(cell: mockCell, sectionItem: sectionItem1, at: indexPath)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.cell, mockCell)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.sectionItem, sectionItem1)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.indexPath, indexPath)
    
        // Test didEndDisplaying(cell:sectionItem:at:)
        anySectionController.didEndDisplaying(cell: mockCell, sectionItem: sectionItem1, at: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.cell, mockCell)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.sectionItem, sectionItem1)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.indexPath, indexPath)
    
        // Test willDisplay(supplementaryView:at:)
        let mockSupplementaryView = UICollectionReusableView()
        anySectionController.willDisplay(supplementaryView: mockSupplementaryView, at: indexPath)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.view, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.indexPath, indexPath)
    
        // Test didEndDisplaying(supplementaryView:at:)
        anySectionController.didEndDisplaying(supplementaryView: mockSupplementaryView, at: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.view, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.indexPath, indexPath)
    
        // Test sectionWillDisplay
        anySectionController.sectionWillDisplay()
        XCTAssertTrue(mockSectionController.sectionDisplaying)
    
        // Test sectionDidEndDisplaying
        anySectionController.sectionDidEndDisplaying()
        XCTAssertFalse(mockSectionController.sectionDisplaying)
    }
    
    func testEmbededSectionController() {
        let anySectionController = mockSectionController.anySectionController()
        XCTAssert(anySectionController.embededSectionController === mockSectionController)
    }
}
    
private extension String {
    static let item1 = "item1"
    static let item2 = "item2"
}
