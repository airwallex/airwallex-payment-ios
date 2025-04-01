//
//  CollectionViewManager.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

@MainActor protocol CollectionViewSectionProvider: AnyObject {
    associatedtype SectionType: Hashable & Sendable
    associatedtype ItemType: Hashable & Sendable
    func sections() -> [SectionType]
    func sectionController(for section: SectionType) -> AnySectionController<SectionType, ItemType>
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]?
}

@MainActor
class CollectionViewManager<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable, SectionProvider: CollectionViewSectionProvider>: NSObject, UICollectionViewDelegate where SectionProvider.SectionType == SectionType, SectionProvider.ItemType == ItemType {
    
    weak var sectionDataSource: SectionProvider?
    private(set) var sections = [SectionType]()
    private(set) var sectionControllers = [SectionType: AnySectionController<SectionType, ItemType>]()
    
    private(set) var diffableDataSource: UICollectionViewDiffableDataSource<SectionType, ItemType>!
    private var context: CollectionViewContext<SectionType, ItemType>!
    private(set) var collectionView: UICollectionView!
    
    private let displayHandler = SectionDisplayHandler<SectionType, ItemType>()
    
    init(viewController: UIViewController,
         sectionProvider: SectionProvider,
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
                    assert(false, "invalid section index")
                    return nil
                }
                return controller.layout(environment: environment)
            },
            configuration: listConfiguration
        )
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        
        diffableDataSource = UICollectionViewDiffableDataSource<SectionType, ItemType>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                guard let self, let sectionType = self.sections[safe: indexPath.section],
                      let sectionController = self.sectionControllers[sectionType] else {
                    assert(false, "invalid section index")
                    return UICollectionViewCell()
                }
                return sectionController.cell(for: itemIdentifier, at: indexPath)
            }
        )
        
        diffableDataSource.supplementaryViewProvider = {[weak self] (collectionView, elementKind, indexPath) in
            guard let self else { return nil }
            if let boundaryItem = boundaryItems?.first(where: { $0.elementKind == elementKind}) {
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
            viewController: viewController,
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
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections(sections)
        for section in sections {
            var controller = sectionControllers[section]
            if controller == nil {
                let sectionController = sectionDataSource.sectionController(for: section)
                sectionController.bind(context: context)
                sectionControllers[section] = sectionController
                controller = sectionController
            } else {
                controller?.updateItemsIfNecessary()
            }
            let items = controller?.items ?? []
            snapshot.appendItems(items, toSection: section)
        }
        if forceReload {
            snapshot.reloadSections(sections)
        }
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func performUpdates(section: SectionType, updateItems: Bool = true, forceReload: Bool = false, animatingDifferences: Bool = false) {
        guard let controller = sectionControllers[section] else { return }
        var snapshot = diffableDataSource.snapshot()
        if updateItems {
            controller.updateItemsIfNecessary()
        }
        let items = snapshot.itemIdentifiers(inSection: section)
        snapshot.deleteItems(items)
        let newItems = controller.items
        snapshot.appendItems(newItems, toSection: section)
        if forceReload {
            snapshot.reloadSections([section])
        }
        diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = sections[safe: indexPath.section],
              let controller = sectionControllers[section],
              let itemIdentifier = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        controller.collectionView(didSelectItem: itemIdentifier, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let itemIdentifier = diffableDataSource.itemIdentifier(for: indexPath),
              let section = sections[safe: indexPath.section],
              let sectionController = sectionControllers[section] else {
            assert(false, "section and item for found for indexPath: \(indexPath)")
            return
        }
        displayHandler.willDisplay(
            cell: cell,
            for: sectionController,
            itemIdentifier: itemIdentifier,
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
        if indexPath.indices.count == 1 {
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
        displayHandler.didEndDisplaying(supplementaryView: view, indexPath: indexPath)
    }
}
