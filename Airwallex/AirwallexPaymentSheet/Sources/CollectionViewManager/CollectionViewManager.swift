//
//  CollectionViewManager.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

@MainActor protocol CollectionViewSectionProvider: AnyObject {
    associatedtype SectionType: Hashable & Sendable
    associatedtype ItemType: Hashable & Sendable
    func sections() -> [SectionType]
    func sectionController(for section: SectionType) -> AnySectionController<SectionType, ItemType>
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]?
}

@MainActor
class CollectionViewManager<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable, SectionProvider: CollectionViewSectionProvider>: NSObject, UICollectionViewDelegate where SectionProvider.SectionType == SectionType, SectionProvider.ItemType == ItemType {
    
    /// Type alias for the compound item type used in the diffable data source
    typealias SectionItem = CompoundItem<SectionType, ItemType>
    
    weak var sectionDataSource: SectionProvider?
    private(set) var sections = [SectionType]()
    private(set) var sectionControllers = [SectionType: AnySectionController<SectionType, ItemType>]()
    
    /// The diffable data source uses SectionItem to ensure global uniqueness of item identifiers
    private(set) var diffableDataSource: UICollectionViewDiffableDataSource<SectionType, SectionItem>!
    private var context: CollectionViewContext<SectionType, ItemType>!
    private(set) var collectionView: UICollectionView!
    
    private let displayHandler = SectionDisplayHandler<SectionType, ItemType>()
    
    init(sectionProvider: SectionProvider,
         listConfiguration: UICollectionViewCompositionalLayoutConfiguration? = nil) {
        self.sectionDataSource = sectionProvider
        super.init()

        let listConfiguration = listConfiguration ?? UICollectionViewCompositionalLayoutConfiguration()
        let boundaryItems = sectionProvider.listBoundaryItemProviders()
        if let boundaryLayoutItems = boundaryItems?.map({ $0.layout }) {
            listConfiguration.boundarySupplementaryItems = boundaryLayoutItems
        }
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] index, environment in
                guard let self,
                      let sectionType = self.sections[safe: index],
                      let controller = self.sectionControllers[sectionType] else {
                    assert(false, "invalid section index: \(index), sections: \(String(describing: self?.sectionControllers))")
                    return nil
                }
                return controller.layout(environment: environment)
            },
            configuration: listConfiguration
        )
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self

        diffableDataSource = UICollectionViewDiffableDataSource<SectionType, SectionItem>(
            collectionView: collectionView,
            cellProvider: { [weak self] _, indexPath, sectionItem in
                guard let self, let sectionType = self.sections[safe: indexPath.section],
                      let sectionController = self.sectionControllers[sectionType] else {
                    assert(false, "invalid section index")
                    return UICollectionViewCell()
                }
                // Pass the compound item directly to section controller
                return sectionController.cell(for: sectionItem, at: indexPath)
            }
        )

        diffableDataSource.supplementaryViewProvider = {[weak self] (_, elementKind, indexPath) in
            guard let self else { return nil }
            if let boundaryItem = boundaryItems?.first(where: { $0.elementKind == elementKind }) {
                return self.context.dequeueReusableSupplementaryView(ofKind: elementKind, viewClass: boundaryItem.reusableView, indexPath: indexPath)
            }
            guard let section = self.sections[safe: indexPath.section],
                  let sectionController = self.sectionControllers[section] else {
                assert(false, "UI not consistance with data source")
                return nil
            }

            return sectionController.supplementaryView(for: elementKind, at: indexPath)
        }

        context = CollectionViewContext(
            collectionView: collectionView,
            layout: layout,
            dataSource: diffableDataSource,
            performSectionUpdates: { [weak self] in
                self?.performUpdates(section: $0, updateItems: $1, forceReload: $2, animatingDifferences: $3)
            },
            performUpdates: { [weak self] in
                self?.performUpdates(forceReload: $0, animatingDifferences: $1)
            }
        )

        for item in boundaryItems ?? [] {
            context.register(item.reusableView, forSupplementaryViewOfKind: item.elementKind)
        }
    }
    
    func performUpdates(forceReload: Bool = false, animatingDifferences: Bool = false) {
        guard let sectionDataSource else { return }
        sections = sectionDataSource.sections()
        var newSnapshot = NSDiffableDataSourceSnapshot<SectionType, SectionItem>()
        newSnapshot.appendSections(sections)
        for section in sections {
            var controller = sectionControllers[section]
            if controller == nil {
                let sectionController = sectionDataSource.sectionController(for: section)
                sectionController.bind(context: context)
                sectionControllers[section] = sectionController
                controller = sectionController
                // delay first call of `updateItemsIfNecessary`
                // until `sectionWillDisplay` called
            } else {
                controller?.updateItemsIfNecessary()
            }
            // Wrap raw items in SectionItem for global uniqueness
            let rawItems = controller?.items ?? []
            let items = rawItems.map { SectionItem(section, $0) }
            newSnapshot.appendItems(items, toSection: section)
        }
        if forceReload {
            let existingItems = Set(diffableDataSource.snapshot().itemIdentifiers)
            let toReload = newSnapshot.itemIdentifiers.reduce(into: [SectionItem]()) { partialResult, item in
                if existingItems.contains(item) { partialResult.append(item) }
            }
            newSnapshot.reloadItems(toReload)
        }
        
        diffableDataSource.apply(newSnapshot, animatingDifferences: animatingDifferences)
    }
    
    func performUpdates(section: SectionType, updateItems: Bool = true, forceReload: Bool = false, animatingDifferences: Bool = false) {
        var snapshot = diffableDataSource.snapshot()
        guard snapshot.sectionIdentifiers.contains(section) else {
            // section may not exist if multiple updates happened at the same time
            return
        }
        guard let controller = sectionControllers[section] else { return }
        if updateItems {
            controller.updateItemsIfNecessary()
        }
        let existingItems = snapshot.itemIdentifiers(inSection: section)
        snapshot.deleteItems(existingItems)
        // Wrap raw items in SectionItem for global uniqueness
        let newItems = controller.items.map { SectionItem(section, $0) }
        snapshot.appendItems(newItems, toSection: section)
        if forceReload {
            let existingSet = Set(existingItems)
            let toReload = newItems.reduce(into: [SectionItem]()) { partialResult, item in
                if existingSet.contains(item) { partialResult.append(item) }
            }
            snapshot.reloadItems(toReload)
        }
        
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = sections[safe: indexPath.section],
              let controller = sectionControllers[section],
              let sectionItem = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        // Pass the compound item directly to section controller
        controller.collectionView(didSelectItem: sectionItem, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let sectionItem = diffableDataSource.itemIdentifier(for: indexPath),
              let section = sections[safe: indexPath.section],
              let sectionController = sectionControllers[section] else {
            assert(false, "section and item for found for indexPath: \(indexPath)")
            return
        }
        // Pass the compound item directly to display handler
        displayHandler.willDisplay(
            cell: cell,
            for: sectionController,
            sectionItem: sectionItem,
            indexPath: indexPath
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        displayHandler.didEndDisplaying(cell: cell, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        guard indexPath.indices.count == 2 else {
            // list boundary item displayed
            // just ignore for now
            return
        }
        guard let section = sections[safe: indexPath.section],
              let sectionController = sectionControllers[section] else {
            assert(false, "section not found for element of kind: \(elementKind), at indexPath: \(indexPath)")
            return
        }
        
        displayHandler.willDisplay(
            supplementaryView: view,
            for: sectionController,
            indexPath: indexPath
        )
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplayingSupplementaryView view: UICollectionReusableView,
                        forElementOfKind elementKind: String,
                        at indexPath: IndexPath) {
        guard indexPath.indices.count == 2 else { return }
        displayHandler.didEndDisplaying(supplementaryView: view, indexPath: indexPath)
    }
}
