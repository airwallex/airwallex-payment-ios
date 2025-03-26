//
//  SimpleSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class SimpleSectionController<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: SectionController {
    
    typealias CellProvider = (CollectionViewContext<SectionType, ItemType>, ItemType, IndexPath) -> UICollectionViewCell
    typealias SelectionHandler = (ItemType, IndexPath, UICollectionViewCell) -> Void
    
    private let cellProvider: CellProvider
    private let layout: NSCollectionLayoutSection
    private let selectionHandler: SelectionHandler?
    
    init(section: SectionType,
         item: ItemType,
         layout: NSCollectionLayoutSection,
         cellProvider: @escaping CellProvider,
         selectionHandler: SelectionHandler? = nil) {
        self.section = section
        self.cellProvider = cellProvider
        self.items = [item]
        self.layout = layout
        self.selectionHandler = selectionHandler
    }
    
    //  MARK: - SectionController
    private(set) var context: CollectionViewContext<SectionType, ItemType>!
    
    let section: SectionType
    private(set) var items: [ItemType]
    
    func bind(context: CollectionViewContext<SectionType, ItemType>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: ItemType, at indexPath: IndexPath) -> UICollectionViewCell {
        return cellProvider(context, itemIdentifier, indexPath)
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        return layout
    }
    
    func collectionView(didSelectItem item: ItemType, at indexPath: IndexPath) {
        guard let cell = context.cellForItem(item) else { return }
        selectionHandler?(item, indexPath, cell)
    }
}
