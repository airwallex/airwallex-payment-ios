//
//  MockSectionController.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/27.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class MockSectionController<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: SectionController {

    typealias SectionItem = CompoundItem<SectionType, ItemType>
    
    var updateItemsIfNecessaryCalled: Bool = false
    var didSelectItemCalled: (sectionItem: SectionItem, indexPath: IndexPath)? = nil
    var willDisplayCellCalled: (cell: UICollectionViewCell, sectionItem: SectionItem, indexPath: IndexPath)? = nil
    var didEndDisplayingCellCalled: (cell: UICollectionViewCell, sectionItem: SectionItem, indexPath: IndexPath)? = nil
    var willDisplaySupplementaryViewCalled: (view: UICollectionReusableView, indexPath: IndexPath)? = nil
    var didEndDisplayingSupplementaryViewCalled: (view: UICollectionReusableView, indexPath: IndexPath)? = nil
    var sectionDisplaying: Bool = false
    var cellForItemAtIndexPathCalled: (sectionItem: SectionItem, indexPath: IndexPath)? = nil
    var supplementaryViewForElementKindAtIndexPathCalled: (elementKind: String, indexPath: IndexPath)? = nil
    var sectionLayoutCalled: (any NSCollectionLayoutEnvironment)? = nil
    
    var context: CollectionViewContext<SectionType, ItemType>!
    
    var section: SectionType
    
    var items: [ItemType]
    
    init(section: SectionType, items: [ItemType]) {
        self.section = section
        self.items = items
    }
    
    func bind(context: CollectionViewContext<SectionType, ItemType>) {
        self.context = context
    }
    
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell {
        cellForItemAtIndexPathCalled = (sectionItem, indexPath)
        let cell = context.dequeueReusableCell(LabelCell.self, for: sectionItem, indexPath: indexPath)
        cell.label.text = "\(section)-\(sectionItem.item)"
        return cell
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        sectionLayoutCalled = environment
        
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
    
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
        didSelectItemCalled = (sectionItem, indexPath)
    }
    
    func willDisplay(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath) {
        willDisplayCellCalled = (cell, sectionItem, indexPath)
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath) {
        // store parameters in property for testing
        didEndDisplayingCellCalled = (cell, sectionItem, indexPath)
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
    
    func resetMethodCalledStatus() {
        updateItemsIfNecessaryCalled = false
        didSelectItemCalled = nil
        willDisplayCellCalled = nil
        didEndDisplayingCellCalled = nil
        willDisplaySupplementaryViewCalled = nil
        didEndDisplayingSupplementaryViewCalled = nil
        cellForItemAtIndexPathCalled = nil
        supplementaryViewForElementKindAtIndexPathCalled = nil
        sectionLayoutCalled = nil
    }
}
