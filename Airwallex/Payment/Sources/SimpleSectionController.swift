//
//  SimpleSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

class SimpleSectionController: SectionController {
    
    typealias CellProvider = (CollectionViewContext<SectionType, ItemType>, ItemType, IndexPath) -> UICollectionViewCell
    
    private let cellProvider: CellProvider
    private let layout: NSCollectionLayoutSection
    
    init(section: SectionType,
         item: ItemType,
         layout: NSCollectionLayoutSection,
         cellProvider: @escaping CellProvider) {
        self.section = section
        self.cellProvider = cellProvider
        self.items = [item]
        self.layout = layout
    }
    
    //  MARK: - SectionController
    private(set) var context: CollectionViewContext<SectionType, ItemType>!
    
    let section: SectionType
    private(set) var items: [ItemType]
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        return cellProvider(context, itemIdentifier, indexPath)
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero.top(.spacing_24).horizontal(.spacing_16)
        return section
        
        return layout
    }
}
