//
//  CollectionViewManager.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

protocol CollectionViewSectionProvider: AnyObject {
    associatedtype SectionType: Hashable & Sendable
    associatedtype ItemType: Hashable & Sendable
    func sections() -> [SectionType]
    func sectionController(for section: SectionType) -> AnySectionController<SectionType, ItemType>
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]?
}

@MainActor
class CollectionViewManager<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable, SectionProvider: CollectionViewSectionProvider>: NSObject, UICollectionViewDelegate where SectionProvider.SectionType == SectionType, SectionProvider.ItemType == ItemType {
    
    private weak var sectionDataSource: SectionProvider?
    private var sections = [SectionType]()
    private var sectionControllers = [SectionType: AnySectionController<SectionType, ItemType>]()
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<SectionType, ItemType>!
    private var context: CollectionViewContext<SectionType, ItemType>!
    private(set) var collectionView: UICollectionView!
    
    private let displayHandler = SectionDisplayHandler<SectionType, ItemType>()
    
    init(viewController: UIViewController,
         sectionProvider: SectionProvider,
         listConfiguration: UICollectionViewCompositionalLayoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()) {
        self.sectionDataSource = sectionProvider
        super.init()
        
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
        guard let section = sections[safe: indexPath.section],
              let sectionController = sectionControllers[section] else {
            assert(false, "section for found for element of kind: \(elementKind), at indexPath: \(indexPath)")
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

class CollectionViewContext<Section: Hashable & Sendable, Item: Hashable & Sendable>: DebugLoggable {
    private(set) weak var viewController: UIViewController?
    private weak var collectionView: UICollectionView!
    private weak var layout: UICollectionViewCompositionalLayout!
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, Item>
    private var _performUpdates: (Bool, Bool) -> Void
    private var _performUpdatesForSection: (Section, Bool, Bool, Bool) -> Void
    
    init(viewController: UIViewController,
         collectionView: UICollectionView,
         layout: UICollectionViewCompositionalLayout,
         dataSource: UICollectionViewDiffableDataSource<Section, Item>,
         performSectionUpdates: @escaping (Section, Bool, Bool, Bool) -> Void,
         performUpdates: @escaping (Bool, Bool) -> Void) {
        self.viewController = viewController
        self.collectionView = collectionView
        self.layout = layout
        self.dataSource = dataSource
        self._performUpdates = performUpdates
        self._performUpdatesForSection = performSectionUpdates
    }
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        return dataSource.snapshot()
    }
    
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,
                       animatingDifferences: Bool = false,
                       completion: (() -> Void)? = nil) {
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    func invalidateLayout(for items: [Item], animated: Bool = false) {
        var indexPaths = [IndexPath]()
        for item in items {
            guard let indexPath = dataSource.indexPath(for: item) else { continue }
            indexPaths.append(indexPath)
        }
        invalidateLayout(at: indexPaths, animated: animated)
    }
    
    func invalidateLayout(at indexPaths: [IndexPath], animated: Bool = false) {
        let invalidationContext = UICollectionViewLayoutInvalidationContext()
        invalidationContext.invalidateItems(at: indexPaths)
        layout.invalidateLayout(with: invalidationContext)
        if animated {
            collectionView.performBatchUpdates(nil)
        } else {
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates(nil)
            }
        }
    }
    
    func reload(sections: [Section], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        let existingSections = Set(snapshot.sectionIdentifiers)
        assert(existingSections.isSuperset(of: sections), "reload sections not existing")
        let sections = Array(existingSections.intersection(sections))
        snapshot.reloadSections(sections)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func reload(items: [Item], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        let existingItems = Set(snapshot.itemIdentifiers)
        assert(existingItems.isSuperset(of: items), "reload items not existing")
        let items = Array(existingItems.intersection(items))
        snapshot.reloadItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    /// Reconfigures cells instead of reloading them.
    /// Calling this method will not trigger any `UICollectionViewDataSource` methods.
    /// - Parameters:
    ///   - items: The items that need to be reconfigured.
    ///   - invalidateLayout: A boolean indicating whether to invalidate the layout of the items.
    ///   - configurer: A closure that allows you to configure each cell.
    ///     - If no closure is provided, the method attempts to cast the cell to `ViewConfigurable` and call `reconfigure`,
    ///       which updates the cell using the current `viewModel` without replacing it.
    ///     - `Important!` If you need to configure the cell with a new `viewModel`, you should provide a `configurer` block and update the cell in the block
    ///   - animatingDifferences: A boolean indicating whether to animate changes.
    func reconfigure(items: [Item],
                     invalidateLayout: Bool,
                     configurer: ((UICollectionViewCell) -> Void)? = nil,
                     animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        guard !items.isEmpty else { return }
        for item in items {
            guard let cell = cellForItem(item) else {
                continue
            }
            if let configurer {
                configurer(cell)
            } else {
                if let cell = cell as? any ViewConfigurable {
                    cell.reconfigure()
                } else {
                    assert(false, "make your cell conforms to ViewConfigurable")
                }
            }
        }
        if invalidateLayout {
            self.invalidateLayout(for: items)
        }
        // TODO: Update to `snapshot.reconfigureItems(items)` once the deployment target is iOS 15.0 or later.
        //            snapshot.reconfigureItems(items)
        //            dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func delete(items: [Item], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        let existingItems = Set(snapshot.itemIdentifiers)
        assert(existingItems.isSuperset(of: items), "delete items not existing")
        let items = Array(existingItems.intersection(items))
        snapshot.deleteItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func performUpdates(forceReload: Bool = false, animatingDifferences: Bool = false) {
        _performUpdates(forceReload, animatingDifferences)
    }
    
    func performUpdates(_ section: Section,
                        updateItems: Bool = true,
                        forceReload: Bool = false,
                        animatingDifferences: Bool = false) {
        _performUpdatesForSection(section, updateItems, forceReload, animatingDifferences)
    }
    
    func scroll(to item: Item, position: UICollectionView.ScrollPosition, animated: Bool = false) {
        guard let indexPath = dataSource.indexPath(for: item) else { return }
        collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
    }
    
    func cellForItem(_ item: Item) -> UICollectionViewCell? {
        guard let indexPath = dataSource.indexPath(for: item) else { return nil }
        return collectionView.cellForItem(at: indexPath)
    }
    
    func endEditing(_ force: Bool = true) {
        collectionView.endEditing(force)
    }
    
    func activateNextRespondableCell(section: Section, itemIdentifier: Item) -> Bool {
        let snapshot = dataSource.snapshot()
        guard let indexPath = dataSource.indexPath(for: itemIdentifier) else {
            return false
        }
        let itemCount = snapshot.numberOfItems(inSection: section)
        for index in (indexPath.item + 1)..<itemCount {
            let nextIndexPath = IndexPath(item: index, section: indexPath.section)
            guard let cell = collectionView.cellForItem(at: nextIndexPath),
                  cell.canBecomeFirstResponder else {
                continue
            }
            return cell.becomeFirstResponder()
        }
        return false
    }
    
    // MARK: - register reusable views
    
    private lazy var registeredCells = Set<String>()
    private lazy var registeredSupplementaryViews = Set<String>()
    
    func register<T: UICollectionViewCell & ViewReusable>(_ cellClass: T.Type) {
        guard !registeredCells.contains(cellClass.reuseIdentifier) else { return }
        collectionView.register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        registeredCells.insert(cellClass.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView & ViewReusable>(_ viewClass: T.Type, forSupplementaryViewOfKind elementKind: String) {
        let key = elementKind + viewClass.reuseIdentifier
        guard !registeredSupplementaryViews.contains(key) else { return }
        collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier)
        registeredSupplementaryViews.insert(key)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell & ViewReusable>(_ cellClass: T.Type, for item: String, indexPath: IndexPath) -> T {
        register(cellClass)
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView & ViewReusable>(ofKind elementKind: String, viewClass: T.Type, indexPath: IndexPath) -> T {
        register(viewClass, forSupplementaryViewOfKind: elementKind)
        return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier, for: indexPath) as! T
    }
}
