//
//  MockSectionController.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
@testable import Payment

class MockSectionController: SectionController {
    
    private(set) var updateItemsIfNecessaryCalled: Bool = false
    private(set) var didSelectItemCalled: (String, IndexPath)? = nil
    private(set) var willDisplayCellCalled: (UICollectionViewCell, ItemType, IndexPath)? = nil
    private(set) var didEndDisplaying: (UICollectionViewCell, ItemType, IndexPath)? = nil
    private(set) var willDisplaySupplementaryViewCalled: (UICollectionReusableView, IndexPath)? = nil
    private(set) var didEndDisplayingSupplementaryViewCalled: (UICollectionReusableView, IndexPath)? = nil
    private(set) var sectionWillDisplayCalled: Bool = false
    private(set) var sectionDidEndDisplayingCalled: Bool = false
    private(set) var cellForItemAtIndexPathCalled: (String, IndexPath)? = nil
    private(set) var supplementaryViewForElementKindAtIndexPathCalled: (String, IndexPath)? = nil
    
    var context: Payment.CollectionViewContext<String, String>!
    
    var section: String
    
    var items: [String]
    
    init(section: String, items: [String]) {
        self.section = section
        self.items = items
    }
    
    func bind(context: Payment.CollectionViewContext<String, String>) {
        self.context = context
    }
    
    func cell(for item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        cellForItemAtIndexPathCalled = (item, indexPath)
        return UICollectionViewCell()
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let mockSectionLayout = NSCollectionLayoutSection(
            group: NSCollectionLayoutGroup.horizontal(
                layoutSize: size,
                subitems: [NSCollectionLayoutItem(layoutSize: size)]
            )
        )
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(22)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        mockSectionLayout.boundarySupplementaryItems = [header]
        return mockSectionLayout
    }
    
    func updateItemsIfNecessary() {
        // do nothing by default
        updateItemsIfNecessaryCalled = true
    }
    
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        supplementaryViewForElementKindAtIndexPathCalled = (elementKind, indexPath)
        // provide supplementary view in you concrete SectionController
        return UICollectionReusableView()
    }
    
    func collectionView(didSelectItem itemIdentifier: ItemType, at indexPath: IndexPath) {
        didSelectItemCalled = (itemIdentifier, indexPath)
    }
    
    func willDisplay(cell: UICollectionViewCell, itemIdentifier: ItemType, at indexPath: IndexPath) {
        willDisplayCellCalled = (cell, itemIdentifier, indexPath)
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, itemIdentifier: ItemType, at indexPath: IndexPath) {
        // store parameters in property for testing
        didEndDisplaying = (cell, itemIdentifier, indexPath)
    }
    
    func willDisplay(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        willDisplaySupplementaryViewCalled = (supplementaryView, indexPath)
    }
    
    func didEndDisplaying(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        didEndDisplayingSupplementaryViewCalled = (supplementaryView, indexPath)
    }
    
    func sectionWillDisplay() {
        sectionWillDisplayCalled = true
    }
    
    func sectionDidEndDisplaying() {
        sectionDidEndDisplayingCalled = true
    }
}
