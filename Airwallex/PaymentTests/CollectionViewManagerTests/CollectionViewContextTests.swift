//
//  CollectionViewContextTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import Payment

@MainActor class CollectionViewContextTests: XCTestCase {

    private var mockManager: CollectionViewManager<Section, Item, MockSectionProvider>!
    private var mockProvider: MockSectionProvider!
    var mockViewController: UIViewController!
    
    override func setUp() {
        super.setUp()
        mockViewController = UIViewController()
        mockProvider = MockSectionProvider()
        mockManager = CollectionViewManager(
            viewController: mockViewController,
            sectionProvider: mockProvider
        )
        let collectionView = mockManager.collectionView
        collectionView?.frame = mockViewController.view.bounds
        mockViewController.view.addSubview(mockManager.collectionView)
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func testContextBinding() {
        func testSectionControllerContextBinding() {
            mockProvider.status = .A
            // Start from status A
            let sectionController = mockProvider.sectionControllerA
            XCTAssertNil(sectionController.context)
            // Perform updates to bind context
            mockManager.performUpdates()
            mockManager.collectionView.layoutIfNeeded()

            // Check context is bound after update
            XCTAssertNotNil(sectionController.context)

            // Check viewController on context is mockViewController and not nil
            XCTAssertEqual(sectionController.context.viewController, mockViewController)
        }
    }
    
    func testCurrentSnapshot() {
        // Generate snapshot from context
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        let contextSnapshot = mockProvider.sectionControllerA.context.currentSnapshot()

        // Generate snapshot directly from mockManager
        let managerSnapshot = mockManager.diffableDataSource.snapshot()

        // Compare the two snapshots
        XCTAssertEqual(contextSnapshot.sectionIdentifiers, managerSnapshot.sectionIdentifiers)
        XCTAssertEqual(contextSnapshot.itemIdentifiers, managerSnapshot.itemIdentifiers)
    }
    
    func testApplySnapshot() {
        // Start from status A
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        // Get context from sectionControllerA
        guard let context = mockProvider.sectionControllerA.context else {
            XCTFail("Context should not be nil")
            return
        }

        // Get current snapshot from context
        var snapshot = context.currentSnapshot()

        // Insert section B and item B1
        snapshot.appendItems([.A2, .B1, .B2], toSection: .A)

        // Apply the modified snapshot to the context
        context.applySnapshot(snapshot)
        mockManager.collectionView.layoutIfNeeded()

        // Assert the status of the current snapshot
        let appliedSnapshot = context.currentSnapshot()
        XCTAssertEqual(appliedSnapshot.sectionIdentifiers, [.A])
        XCTAssertEqual(appliedSnapshot.itemIdentifiers(inSection: .A), [.A1, .A2, .B1, .B2])
    }
    
    func testInvalidateLayoutForItems() {
        // Start from status AB
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        // Get context from sectionControllerA
        guard let context = mockProvider.sectionControllerA.context else {
            XCTFail("Context should not be nil")
            return
        }
        // reset status
        mockProvider.sectionControllerA.sectionLayoutCalled = nil
        mockProvider.sectionControllerB.sectionLayoutCalled = nil
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        mockProvider.sectionControllerB.cellForItemAtIndexPathCalled = nil
        
        // Invalidate layout for specific items
        context.invalidateLayout(for: [.B2])
        mockManager.collectionView.layoutIfNeeded()

        // Verify that the layout invalidation was triggered
        XCTAssertNil(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled)
        XCTAssertNil(mockProvider.sectionControllerB.cellForItemAtIndexPathCalled)
        XCTAssertNotNil(mockProvider.sectionControllerB.sectionLayoutCalled)
    }
    
    func testReloadSections() {
        // Start from status A
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        // Get context from sectionControllerA
        guard let context = mockProvider.sectionControllerA.context else {
            XCTFail("Context should not be nil")
            return
        }

        // Reset tracking variables
        mockProvider.sectionControllerA.sectionLayoutCalled = nil
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        mockProvider.sectionControllerA.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerA.willDisplayCellCalled = nil

        // Reload sections
        context.reload(sections: [.A])
        mockManager.collectionView.layoutIfNeeded()

        // Verify that the appropriate methods were called
        XCTAssertNotNil(mockProvider.sectionControllerA.sectionLayoutCalled)
        XCTAssertNotNil(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled)
        XCTAssertNotNil(mockProvider.sectionControllerA.didEndDisplayingCellCalled)
        XCTAssertNotNil(mockProvider.sectionControllerA.willDisplayCellCalled)
    }
    
    func testReloadItems() {
        // Start from status A
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        
        // Get context from sectionControllerA
        guard let context = mockProvider.sectionControllerA.context else {
            XCTFail("Context should not be nil")
            return
        }
        
        // Reset tracking variables
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        mockProvider.sectionControllerA.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerA.willDisplayCellCalled = nil
        
        // Reload sections
        context.reload(items: [.A1])
        mockManager.collectionView.layoutIfNeeded()
        
        // Verify that the appropriate methods were called
        XCTAssertEqual(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled?.0, Item.A1)
        XCTAssertEqual(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled?.1, IndexPath(item: 0, section: 0))
        XCTAssertEqual(mockProvider.sectionControllerA.didEndDisplayingCellCalled?.1, Item.A1)
        XCTAssertEqual(mockProvider.sectionControllerA.didEndDisplayingCellCalled?.2, IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(mockProvider.sectionControllerA.willDisplayCellCalled?.1, Item.A1)
        XCTAssertEqual(mockProvider.sectionControllerA.willDisplayCellCalled?.2, IndexPath(item: 0, section: 0))
    }
    
    func testReconfigureItems() {
        let updated = "updated"
        // Start with status A
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()

        // Get context from sectionControllerA
        guard let context = mockProvider.sectionControllerA.context else {
            XCTFail("Context should not be nil")
            return
        }

        // Reset tracking variables
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        mockProvider.sectionControllerA.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerA.willDisplayCellCalled = nil
        mockProvider.sectionControllerA.sectionLayoutCalled = nil
        
        // get text before reconfigure
        guard let textA1 = (mockProvider.sectionControllerA.context.cellForItem(Item.A1) as? LabelCell)?.label.text,
              let textA2 = (mockProvider.sectionControllerA.context.cellForItem(Item.A2) as? LabelCell)?.label.text else {
            XCTFail("unexpected cell")
            return
        }

        // Reconfigure item A1
        context.reconfigure(items: [Item.A1], invalidateLayout: false) { cell in
            let cell = cell as? LabelCell
            cell?.label.text = updated
        }
        mockManager.collectionView.layoutIfNeeded()

        // Verify that the cell's configuration block was called
        guard let textA1_1 = (mockProvider.sectionControllerA.context.cellForItem(Item.A1) as? LabelCell)?.label.text,
              let textA2_1 = (mockProvider.sectionControllerA.context.cellForItem(Item.A2) as? LabelCell)?.label.text else {
            XCTFail("unexpected cell")
            return
        }
        XCTAssertNotEqual(textA1, textA1_1)
        XCTAssertEqual(textA2, textA2_1)
        XCTAssertNil(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled)
        XCTAssertNil(mockProvider.sectionControllerA.didEndDisplayingCellCalled)
        XCTAssertNil(mockProvider.sectionControllerA.willDisplayCellCalled)
        XCTAssertNil(mockProvider.sectionControllerA.sectionLayoutCalled)
        
        // Reset tracking variables
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        mockProvider.sectionControllerA.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerA.willDisplayCellCalled = nil
        mockProvider.sectionControllerA.sectionLayoutCalled = nil
        
        // Reconfigure item A2
        context.reconfigure(items: [Item.A2], invalidateLayout: true) { cell in
            let cell = cell as? LabelCell
            cell?.label.text = updated
        }
        mockManager.collectionView.layoutIfNeeded()
        guard let textA1_2 = (mockProvider.sectionControllerA.context.cellForItem(Item.A1) as? LabelCell)?.label.text,
              let textA2_2 = (mockProvider.sectionControllerA.context.cellForItem(Item.A2) as? LabelCell)?.label.text else {
            XCTFail("unexpected cell")
            return
        }
        XCTAssertEqual(updated, textA1_2)
        XCTAssertEqual(updated, textA2_2)
        XCTAssertNil(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled)
        XCTAssertNil(mockProvider.sectionControllerA.didEndDisplayingCellCalled)
        XCTAssertNil(mockProvider.sectionControllerA.willDisplayCellCalled)
        XCTAssertNotNil(mockProvider.sectionControllerA.sectionLayoutCalled)
    }
}
