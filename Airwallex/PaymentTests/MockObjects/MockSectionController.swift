//
//  MockSectionController.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
@testable import Payment

class MockSectionController<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: SectionController {
    
    var updateItemsIfNecessaryCalled: Bool = false
    var didSelectItemCalled: (ItemType, IndexPath)? = nil
    var willDisplayCellCalled: (UICollectionViewCell, ItemType, IndexPath)? = nil
    var didEndDisplayingCell: (UICollectionViewCell, ItemType, IndexPath)? = nil
    var willDisplaySupplementaryViewCalled: (UICollectionReusableView, IndexPath)? = nil
    var didEndDisplayingSupplementaryViewCalled: (UICollectionReusableView, IndexPath)? = nil
    var sectionDisplaying: Bool = false
    var cellForItemAtIndexPathCalled: (ItemType, IndexPath)? = nil
    var supplementaryViewForElementKindAtIndexPathCalled: (String, IndexPath)? = nil
    
    var context: Payment.CollectionViewContext<SectionType, ItemType>!
    
    var section: SectionType
    
    var items: [ItemType]
    
    init(section: SectionType, items: [ItemType]) {
        self.section = section
        self.items = items
    }
    
    func bind(context: Payment.CollectionViewContext<SectionType, ItemType>) {
        self.context = context
    }
    
    func cell(for item: ItemType, at indexPath: IndexPath) -> UICollectionViewCell {
        cellForItemAtIndexPathCalled = (item, indexPath)
        let cell = context.dequeueReusableCell(LabelCell.self, for: item, indexPath: indexPath)
        cell.label.text = "\(section)-\(item)"
        return cell
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )
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
        return context.dequeueReusableSupplementaryView(ofKind: elementKind, viewClass: PaymentMethodListSeparator.self, indexPath: indexPath)
    }
    
    func collectionView(didSelectItem itemIdentifier: ItemType, at indexPath: IndexPath) {
        didSelectItemCalled = (itemIdentifier, indexPath)
    }
    
    func willDisplay(cell: UICollectionViewCell, itemIdentifier: ItemType, at indexPath: IndexPath) {
        willDisplayCellCalled = (cell, itemIdentifier, indexPath)
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, itemIdentifier: ItemType, at indexPath: IndexPath) {
        // store parameters in property for testing
        didEndDisplayingCell = (cell, itemIdentifier, indexPath)
    }
    
    func willDisplay(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        willDisplaySupplementaryViewCalled = (supplementaryView, indexPath)
    }
    
    func didEndDisplaying(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        didEndDisplayingSupplementaryViewCalled = (supplementaryView, indexPath)
    }
    
    func sectionWillDisplay() {
        sectionDisplaying = true
    }
    
    func sectionDidEndDisplaying() {
        sectionDisplaying = false
    }
}
