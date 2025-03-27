//
//  SectionDisplayHandlerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import Payment

final class SectionDisplayHandlerTests: XCTestCase {
    
    private var sectionDisplayHandler: SectionDisplayHandler<String, String>!
    private var mockSectionController: MockSectionController!
    private var mockAnySectionController: AnySectionController<String, String>!
    private var mockCell: UICollectionViewCell!
    private var mockSupplementaryView: UICollectionReusableView!
    
    @MainActor override func setUp() {
        super.setUp()
        sectionDisplayHandler = SectionDisplayHandler<String, String>()
        mockSectionController = MockSectionController(section: "Section1", items: ["Item1", "Item2"])
        mockAnySectionController = mockSectionController.anySectionController()
        mockCell = UICollectionViewCell()
        mockSupplementaryView = UICollectionReusableView()
    }
    
    @MainActor func testMapCellToSectionController() {
        sectionDisplayHandler.mapCell(
            mockCell,
            to: mockAnySectionController,
            itemIdentifier: "Item1"
        )
        let retrievedController = sectionDisplayHandler.sectionControllerByView(mockCell)
        XCTAssert(retrievedController === mockAnySectionController)
        XCTAssertEqual(sectionDisplayHandler.itemIdentifierByCell(mockCell), "Item1")
    }
    
    @MainActor func testUnmapCell() {
        sectionDisplayHandler.mapCell(mockCell, to: mockAnySectionController, itemIdentifier: "Item1")
        sectionDisplayHandler.unmap(mockCell)
        XCTAssertNil(sectionDisplayHandler.sectionControllerByView(mockCell))
        XCTAssertNil(sectionDisplayHandler.itemIdentifierByCell(mockCell))
    }
    
    @MainActor func testWillDisplayCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, itemIdentifier: "Item1", indexPath: indexPath)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.0, mockCell)
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.1, "Item1")
        XCTAssertEqual(mockSectionController.willDisplayCellCalled?.2, indexPath)
    }
    
    @MainActor func testDidEndDisplayingCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, itemIdentifier: "Item1", indexPath: indexPath)
        sectionDisplayHandler.didEndDisplaying(cell: mockCell, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplaying?.0, mockCell)
        XCTAssertEqual(mockSectionController.didEndDisplaying?.1, "Item1")
        XCTAssertEqual(mockSectionController.didEndDisplaying?.2, indexPath)
    }
    
    @MainActor func testWillDisplaySupplementaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.0, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.willDisplaySupplementaryViewCalled?.1, indexPath)
    }
    
    @MainActor func testDidEndDisplayingSupplementaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        sectionDisplayHandler.didEndDisplaying(supplementaryView: mockSupplementaryView, indexPath: indexPath)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.0, mockSupplementaryView)
        XCTAssertEqual(mockSectionController.didEndDisplayingSupplementaryViewCalled?.1, indexPath)
    }
    
    @MainActor func testSectionWillDisplay() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, itemIdentifier: "Item1", indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionWillDisplayCalled)
    }
    
    @MainActor func testSectionWillDisplaySupplementaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionWillDisplayCalled)
    }
    
    @MainActor func testSectionWillDisplayMultipleViews() {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        XCTAssertTrue(mockSectionController.sectionWillDisplayCalled)
        
        mockSectionController.sectionWillDisplayCalled = false
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, itemIdentifier: "Item1", indexPath: indexPath)
        XCTAssertFalse(mockSectionController.sectionWillDisplayCalled)
    }
    
    @MainActor func testSectionDidEndDisplaying() async {
        let indexPath = IndexPath(row: 0, section: 0)
        sectionDisplayHandler.willDisplay(cell: mockCell, for: mockAnySectionController, itemIdentifier: "Item1", indexPath: indexPath)
        sectionDisplayHandler.willDisplay(supplementaryView: mockSupplementaryView, for: mockAnySectionController, indexPath: indexPath)
        sectionDisplayHandler.didEndDisplaying(cell: mockCell, indexPath: indexPath)
        XCTAssertFalse(mockSectionController.sectionDidEndDisplayingCalled)
        sectionDisplayHandler.didEndDisplaying(supplementaryView: mockSupplementaryView, indexPath: indexPath)
        XCTAssertFalse(mockSectionController.sectionDidEndDisplayingCalled)
        try? await Task.sleep(nanoseconds: 10)
        XCTAssertTrue(mockSectionController.sectionDidEndDisplayingCalled)
    }
}
