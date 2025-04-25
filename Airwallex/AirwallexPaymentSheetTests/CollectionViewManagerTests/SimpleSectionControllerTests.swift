//
//  SimpleSectionControllerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

@MainActor
class SimpleSectionControllerTests: XCTestCase {
    
    var mockContext: MockCollectionViewContext!
    var mockSectionLayout: NSCollectionLayoutSection!
    
    override func setUp() {
        super.setUp()
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        mockSectionLayout = NSCollectionLayoutSection(
            group: NSCollectionLayoutGroup.horizontal(
                layoutSize: size,
                subitems: [NSCollectionLayoutItem(layoutSize: size)]
            )
        )
        mockContext = MockCollectionViewContext()
    }

    @MainActor func testSectionAndItemInitialization() {
        let sectionController = SimpleSectionController(
            section: "payment",
            item: "TestItem",
            layout: mockSectionLayout,
            cellProvider: { _, _, _ in UICollectionViewCell() }
        )
        
        XCTAssertEqual(sectionController.section, "payment")
        XCTAssertEqual(sectionController.items, ["TestItem"])
    }
    
    @MainActor func testBindContext() {
        let sectionController = SimpleSectionController(
            section: "payment",
            item: "TestItem",
            layout: mockSectionLayout,
            cellProvider: { _, _, _ in UICollectionViewCell() }
        )
        
        sectionController.bind(context: mockContext)
        
        XCTAssertNotNil(sectionController.context)
        XCTAssert(sectionController.context === mockContext)
    }
    
    @MainActor func testCellForItem() {
        let mockCell = UICollectionViewCell()
        let sectionController = SimpleSectionController(
            section: "payment",
            item: "TestItem",
            layout: mockSectionLayout,
            cellProvider: { _, _, _ in mockCell }
        )
        sectionController.bind(context: mockContext)
        
        let cell = sectionController.cell(for: "TestItem", at: IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(cell, mockCell)
    }
    
    @MainActor func testLayout() {
        let sectionController = SimpleSectionController(
            section: "payment",
            item: "TestItem",
            layout: mockSectionLayout,
            cellProvider: { _, _, _ in UICollectionViewCell() }
        )
        
        let layout = sectionController.layout(environment: NSCollectionLayoutEnvironmentMock())
        
        XCTAssertEqual(layout, mockSectionLayout)
    }

    @MainActor func testSelectionHandler() {
        var selectedItem: String?
        var selectedIndexPath: IndexPath?
        var selectedCell: UICollectionViewCell?

        let mockCell = UICollectionViewCell()
        let sectionController = SimpleSectionController(
            section: "payment",
            item: "TestItem",
            layout: mockSectionLayout,
            cellProvider: { _, _, _ in mockCell },
            selectionHandler: { item, indexPath, cell in
                selectedItem = item
                selectedIndexPath = indexPath
                selectedCell = cell
            }
        )
        mockContext.mockCell = mockCell
        sectionController.bind(context: mockContext)
        sectionController.collectionView(didSelectItem: "TestItem", at: IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(selectedItem, "TestItem")
        XCTAssertEqual(selectedIndexPath, IndexPath(item: 0, section: 0))
        XCTAssertEqual(selectedCell, mockCell)
    }
}

// Mock for NSCollectionLayoutEnvironment
private class NSCollectionLayoutEnvironmentMock: NSObject, NSCollectionLayoutEnvironment {
    var container: NSCollectionLayoutContainer {
        return NSCollectionLayoutContainerMock()
    }
    var traitCollection: UITraitCollection {
        return UITraitCollection()
    }
}

// Mock for NSCollectionLayoutContainer
private class NSCollectionLayoutContainerMock: NSObject, NSCollectionLayoutContainer {
    var effectiveContentInsets: NSDirectionalEdgeInsets {
        return contentInsets
    }
    
    var contentSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
    var effectiveContentSize: CGSize {
        return contentSize
    }
    var contentInsets: NSDirectionalEdgeInsets {
        return .zero
    }
}
