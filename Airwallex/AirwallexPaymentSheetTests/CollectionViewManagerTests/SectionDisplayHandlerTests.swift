//
//  SectionDisplayHandlerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

final class SectionDisplayHandlerTests: XCTestCase {
    
    private var sectionDisplayHandler: SectionDisplayHandler<String, String>!
    private var mockSectionController: MockSectionController<String, String>!
    private var mockAnySectionController: AnySectionController<String, String>!
    private var mockCell: UICollectionViewCell!
    private var mockSupplementaryView: UICollectionReusableView!
    
    @MainActor override func setUp() {
        super.setUp()
        sectionDisplayHandler = SectionDisplayHandler<String, String>()
        mockSectionController = MockSectionController(section: "Section1", items: [.item1, .item2])
        mockAnySectionController = mockSectionController.anySectionController()
        mockCell = UICollectionViewCell()
        mockSupplementaryView = UICollectionReusableView()
    }
    
    @MainActor func testMapCellToSectionController() {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        sectionDisplayHandler.mapCell(
            mockCell,
            to: mockAnySectionController,
            sectionItem: sectionItem1
        )
        let retrievedController = sectionDisplayHandler.sectionControllerByView(mockCell)
        XCTAssert(retrievedController === mockAnySectionController)
        XCTAssertEqual(sectionDisplayHandler.sectionItemByCell(mockCell), sectionItem1)
    }
    
    @MainActor func testUnmapCell() {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        sectionDisplayHandler.mapCell(mockCell, to: mockAnySectionController, sectionItem: sectionItem1)
        sectionDisplayHandler.unmap(mockCell)
        XCTAssertNil(sectionDisplayHandler.sectionControllerByView(mockCell))
        XCTAssertNil(sectionDisplayHandler.sectionItemByCell(mockCell))
    }
    
    @MainActor func testWillDisplayCell() {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, sectionItem: sectionItem1, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.cell, mockCell)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.sectionItem, sectionItem1)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.indexPath, indexPath)
    }
    
    @MainActor func testDidEndDisplayingCell() {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, sectionItem: sectionItem1, indexPath: indexPath)
        sectionDisplayHandler.didEndDisplaying(cell: mockCell, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.cell, mockCell)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.sectionItem, sectionItem1)
        XCTAssertEqual(mockSectionController.didEndDisplayingCellCalled?.indexPath, indexPath)
    }
    
    @MainActor func testWillDisplaySupplementaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.view, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.indexPath, indexPath)
    }
    
    @MainActor func testDidEndDisplayingSupplementaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        sectionDisplayHandler.didEndDisplaying(supplementaryView: mockSupplementaryView, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.view, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.indexPath, indexPath)
    }
    
    @MainActor func testSectionWillDisplay() {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, sectionItem: sectionItem1, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionDisplaying)
    }
    
    @MainActor func testSectionWillDisplaySupplementaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionDisplaying)
    }
    
    @MainActor func testSectionWillDisplayMultipleViews() {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionDisplaying)
    
        mockSectionController.sectionDisplaying = false
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, sectionItem: sectionItem1, indexPath: indexPath)
        XCTAssertFalse(mockSectionController.sectionDisplaying)
    }
    
    @MainActor func testSectionDidEndDisplaying() async {
        let sectionItem1 = CompoundItem("Section1", String.item1)
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, sectionItem: sectionItem1, indexPath: indexPath)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionDisplaying)
        sectionDisplayHandler.didEndDisplaying(cell: mockCell, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionDisplaying)
        sectionDisplayHandler.didEndDisplaying(supplementaryView: mockSupplementaryView, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionDisplaying)
        try? await Task.sleep(nanoseconds: 10)
        XCTAssertFalse(mockSectionController.sectionDisplaying)
    }
}
    
private extension String {
    static let item1 = "item1"
    static let item2 = "item2"
}
