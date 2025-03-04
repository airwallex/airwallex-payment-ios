//
//  CollectionViewContext.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/4.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

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
    
    func reconfigure(items: [Item], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        let existingItems = Set(snapshot.itemIdentifiers)
        assert(existingItems.isSuperset(of: items), "reload items not existing")
        let items = Array(existingItems.intersection(items))
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems(items)
        } else {
            snapshot.reloadItems(items)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
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
