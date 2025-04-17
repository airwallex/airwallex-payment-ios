//
//  CollectionViewManagerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

@MainActor class CollectionViewManagerTests: XCTestCase {

    private var mockManager: CollectionViewManager<Section, Item, MockABSectionProvider>!
    private var mockProvider: MockABSectionProvider!
    var mockViewController: UIViewController!
    
    override func setUp() {
        super.setUp()
        mockViewController = UIViewController()
        mockProvider = MockABSectionProvider()
        mockManager = CollectionViewManager(
            viewController: mockViewController,
            sectionProvider: mockProvider
        )
        let collectionView = mockManager.collectionView
        collectionView?.frame = mockViewController.view.bounds
        mockViewController.view.addSubview(mockManager.collectionView)
        collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func testDataSource() {
        mockProvider.status = .AB
        mockManager.performUpdates()
        
        XCTAssertEqual(mockManager.sections, mockProvider.sections())
        XCTAssert(mockManager.sectionControllers[Section.A] === mockProvider.anySectionControllerA)
        XCTAssert(mockManager.sectionControllers[Section.B] === mockProvider.anySectionControllerB)
        
        let snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, mockProvider.sections())
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: Section.A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: Section.B), mockProvider.sectionControllerB.items)
        
        let boundarySupplementaryItems = (mockManager.collectionView.collectionViewLayout as! UICollectionViewCompositionalLayout).configuration.boundarySupplementaryItems
        XCTAssert(boundarySupplementaryItems.count == mockProvider.listBoundaryItemProviders()?.count)
        
        XCTAssertEqual(boundarySupplementaryItems.first?.elementKind, mockProvider.listBoundaryItemProviders()?.first?.elementKind)
        XCTAssertEqual(boundarySupplementaryItems.first?.alignment, mockProvider.listBoundaryItemProviders()?.first?.layout.alignment)
    }
    
    func testAppendSection() async {
        // Start with no sections
        mockProvider.status = .None
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [])
        XCTAssertNil(mockManager.sectionControllers[.A])
        XCTAssertNil(mockManager.sectionControllers[.B])
        XCTAssertFalse(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertFalse(mockProvider.sectionControllerB.sectionDisplaying)
        
        var snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [])
        
        // Add Section A
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.A])
        XCTAssert(mockManager.sectionControllers[.A] === mockProvider.anySectionControllerA)
        XCTAssertNil(mockManager.sectionControllers[.B])
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertFalse(mockProvider.sectionControllerB.sectionDisplaying)
        
        snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [.A])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        
        // Append Section B
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.A, .B])
        XCTAssert(mockManager.sectionControllers[.A] === mockProvider.anySectionControllerA)
        XCTAssert(mockManager.sectionControllers[.B] === mockProvider.anySectionControllerB)
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertTrue(mockProvider.sectionControllerB.sectionDisplaying)
        
        snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [.A, .B])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
    }
    
    func testRemoveSection() async {
        // Start with both Section A and Section B
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.A, .B])
        XCTAssert(mockManager.sectionControllers[.A] === mockProvider.anySectionControllerA)
        XCTAssert(mockManager.sectionControllers[.B] === mockProvider.anySectionControllerB)
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertTrue(mockProvider.sectionControllerB.sectionDisplaying)
        
        var snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [.A, .B])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        
        // Remove Section A
        mockProvider.status = .B
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.B])
        XCTAssertNotNil(mockManager.sectionControllers[.A])
        XCTAssert(mockManager.sectionControllers[.B] === mockProvider.anySectionControllerB)
        try? await Task.sleep(nanoseconds: 1)
        XCTAssertFalse(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertTrue(mockProvider.sectionControllerB.sectionDisplaying)
        
        snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [.B])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        
        // Remove Section B
        mockProvider.status = .None
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [])
        XCTAssertNotNil(mockManager.sectionControllers[.A])
        XCTAssertNotNil(mockManager.sectionControllers[.B])
        try? await Task.sleep(nanoseconds: 1)
        XCTAssertFalse(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertFalse(mockProvider.sectionControllerB.sectionDisplaying)
        
        snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [])
    }
    
    func testReorderSection() {
        // Start with sections in order AB
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.A, .B])
        XCTAssert(mockManager.sectionControllers[.A] === mockProvider.anySectionControllerA)
        XCTAssert(mockManager.sectionControllers[.B] === mockProvider.anySectionControllerB)
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertTrue(mockProvider.sectionControllerB.sectionDisplaying)
        
        var snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [.A, .B])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        
        // Reorder sections to BA
        mockProvider.status = .BA
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.B, .A])
        XCTAssert(mockManager.sectionControllers[.B] === mockProvider.anySectionControllerB)
        XCTAssert(mockManager.sectionControllers[.A] === mockProvider.anySectionControllerA)
        XCTAssertTrue(mockProvider.sectionControllerB.sectionDisplaying)
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        
        snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.sectionIdentifiers, [.B, .A])
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
    }
    
    func testUpdateItems() {
        // Start with sections AB
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        XCTAssertEqual(mockManager.sections, [.A, .B])
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        
        // Move items from Section B to Section A
        mockProvider.sectionControllerA.items.append(contentsOf: mockProvider.sectionControllerB.items)
        mockProvider.sectionControllerB.items.removeAll()
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        
        let snapshot = mockManager.diffableDataSource.snapshot()
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(snapshot.itemIdentifiers(inSection: .B), [])
    }
    
    func testForceReloadCellLifecycle() async {
        // Start with Section A
        mockProvider.status = .A
        // simplify status
        mockProvider.sectionControllerA.items = [.A1]
        mockManager.performUpdates(forceReload: true)
        mockManager.collectionView.layoutIfNeeded()
        
        // Verify Section A is displayed
        XCTAssertEqual(mockManager.sections, [.A])
        XCTAssert(mockManager.sectionControllers[.A] === mockProvider.anySectionControllerA)
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        
        // Reset lifecycle tracking properties
        mockProvider.sectionControllerA.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        
        // Perform updates with force reload
        mockManager.performUpdates(forceReload: true)
        mockManager.collectionView.layoutIfNeeded()
        
        // Verify didEndDisplaying was called (because of force reload)
        XCTAssertNotNil(mockProvider.sectionControllerA.didEndDisplayingCellCalled)
        XCTAssertEqual(mockProvider.sectionControllerA.didEndDisplayingCellCalled?.1, .A1) // First item in Section A
        
        // check section displaying status not changed
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)

        // Verify cellForItemAtIndexPathCalled was called
        XCTAssertNotNil(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled)
        XCTAssertEqual(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled?.0, .A1) // First item in Section A

        // check section displaying status not changed
        try? await Task.sleep(nanoseconds: 1)
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
    }
    
    func testPerformSectionUpdate() {
        // Start with status AB
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        
        XCTAssertEqual(mockManager.sections, [.A, .B])
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        
        // Manually update items in Section A and Section B
        mockProvider.sectionControllerA.items = [.A2]
        mockProvider.sectionControllerB.items = [.B2]
        
        // Perform updates only on Section A
        mockManager.performUpdates(section: .A)
        mockManager.collectionView.layoutIfNeeded()
        
        // Assert Section A is updated
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .A), [.A2])
        
        // Assert Section B remains unchanged
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .B), [.B1, .B2])
    }
    
    func testPerformSectionUpdateAndUpdateItems() {
        // Start with status A
        mockProvider.status = .A
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        
        XCTAssertEqual(mockManager.sections, [.A])
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        
        // Update items in Section A
        mockProvider.sectionControllerA.items = [.A2]
        
        // Assert updateItemsIfNecessaryCalled is false before performUpdates
        XCTAssertFalse(mockProvider.sectionControllerA.updateItemsIfNecessaryCalled)
        
        // Perform updates on Section A with updateItems flag
        mockManager.performUpdates(section: .A, updateItems: true)
        mockManager.collectionView.layoutIfNeeded()
        
        // Assert Section A is updated
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .A), [.A2])
        
        // Verify updateItemsIfNecessary was called on MockSectionController
        XCTAssertTrue(mockProvider.sectionControllerA.updateItemsIfNecessaryCalled)
    }
    
    func testPerformSectionUpdateWithForceReload() async {
        // Start with status AB
        mockProvider.status = .AB
        mockManager.performUpdates()
        mockManager.collectionView.layoutIfNeeded()
        
        XCTAssertEqual(mockManager.sections, [.A, .B])
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .A), mockProvider.sectionControllerA.items)
        XCTAssertEqual(mockManager.diffableDataSource.snapshot().itemIdentifiers(inSection: .B), mockProvider.sectionControllerB.items)
        
        // Reset lifecycle tracking properties for Section A and Section B
        mockProvider.sectionControllerA.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerA.cellForItemAtIndexPathCalled = nil
        mockProvider.sectionControllerB.didEndDisplayingCellCalled = nil
        mockProvider.sectionControllerB.cellForItemAtIndexPathCalled = nil
        
        // Perform updates on Section B with force reload
        mockManager.performUpdates(section: .B, forceReload: true)
        mockManager.collectionView.layoutIfNeeded()
        
        // Verify Section A was not force reloaded
        XCTAssertNil(mockProvider.sectionControllerA.didEndDisplayingCellCalled)
        XCTAssertNil(mockProvider.sectionControllerA.cellForItemAtIndexPathCalled)
        
        // Verify Section B was force reloaded
        XCTAssertNotNil(mockProvider.sectionControllerB.didEndDisplayingCellCalled)
        XCTAssertNotNil(mockProvider.sectionControllerB.cellForItemAtIndexPathCalled)
        
        // Verify section displaying status
        XCTAssertTrue(mockProvider.sectionControllerA.sectionDisplaying)
        XCTAssertTrue(mockProvider.sectionControllerB.sectionDisplaying)
    }
}
