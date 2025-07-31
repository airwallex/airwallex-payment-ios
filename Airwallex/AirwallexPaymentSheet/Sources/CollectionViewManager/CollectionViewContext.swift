//
//  CollectionViewContext.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

class CollectionViewContext<Section: Hashable & Sendable, Item: Hashable & Sendable> {
    private(set) weak var viewController: UIViewController?
    private weak var collectionView: UICollectionView!
    private weak var layout: UICollectionViewCompositionalLayout!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>
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
    
    func invalidateLayout(for items: [Item]) {
        var indexPaths = [IndexPath]()
        for item in items {
            guard let indexPath = dataSource.indexPath(for: item) else { continue }
            indexPaths.append(indexPath)
        }
        invalidateLayout(at: indexPaths)
    }
    
    func invalidateLayout(at indexPaths: [IndexPath]) {
        let invalidationContext = UICollectionViewLayoutInvalidationContext()
        invalidationContext.invalidateItems(at: indexPaths)
        layout.invalidateLayout(with: invalidationContext)
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
    func reconfigure(items: [Item],
                     invalidateLayout: Bool,
                     configurer: ((UICollectionViewCell) -> Void)? = nil) {
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
    
    func supplementaryView(forElementKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        let snapshot = currentSnapshot()
        guard 0 <= indexPath.section,
              indexPath.section < snapshot.numberOfSections,
              0 <= indexPath.item,
              indexPath.item < snapshot.numberOfItems(inSection: snapshot.sectionIdentifiers[indexPath.section]) else {
            return nil
        }
        return collectionView.supplementaryView(forElementKind: elementKind, at: indexPath)
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
    private lazy var registeredDecorationViews = Set<String>()
    
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
    
    func register<T: UICollectionReusableView>(_ viewClass: T.Type, forDecorationViewOfKind elementKind: String) {
        let key = elementKind + String(describing: viewClass)
        guard !registeredDecorationViews.contains(key) else { return }
        collectionView.collectionViewLayout.register(viewClass, forDecorationViewOfKind: elementKind)
        registeredDecorationViews.insert(key)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell & ViewReusable>(_ cellClass: T.Type, for item: Item, indexPath: IndexPath) -> T {
        register(cellClass)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
        cell.accessibilityIdentifier = String(describing: item)
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView & ViewReusable>(ofKind elementKind: String, viewClass: T.Type, indexPath: IndexPath) -> T {
        register(viewClass, forSupplementaryViewOfKind: elementKind)
        return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier, for: indexPath) as! T
    }
}
