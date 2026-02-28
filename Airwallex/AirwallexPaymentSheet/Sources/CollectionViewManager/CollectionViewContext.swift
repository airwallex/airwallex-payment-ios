//
//  CollectionViewContext.swift
//  Payment
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexPayment
#endif

/// Context that bridges section controllers with the collection view and its data source.
/// All item operations use SectionItem to ensure global uniqueness.
@MainActor
class CollectionViewContext<Section: Hashable & Sendable, Item: Hashable & Sendable> {

    /// Type alias for the compound item type
    typealias SectionItem = CompoundItem<Section, Item>

    private weak var collectionView: UICollectionView!
    private weak var layout: UICollectionViewCompositionalLayout!
    private var dataSource: UICollectionViewDiffableDataSource<Section, SectionItem>
    private var _performUpdates: (Bool, Bool) -> Void
    private var _performUpdatesForSection: (Section, Bool, Bool, Bool) -> Void

    /// Loading indicator for payment processing
    private var loadingView: LoadingSpinnerView?

    init(collectionView: UICollectionView,
         layout: UICollectionViewCompositionalLayout,
         dataSource: UICollectionViewDiffableDataSource<Section, SectionItem>,
         performSectionUpdates: @escaping (Section, Bool, Bool, Bool) -> Void,
         performUpdates: @escaping (Bool, Bool) -> Void) {
        self.collectionView = collectionView
        self.layout = layout
        self.dataSource = dataSource
        self._performUpdates = performUpdates
        self._performUpdatesForSection = performSectionUpdates
    }
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, SectionItem> {
        return dataSource.snapshot()
    }
    
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Section, SectionItem>,
                       animatingDifferences: Bool = false,
                       completion: (() -> Void)? = nil) {
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }
    
    func invalidateLayout(for items: [SectionItem]) {
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
    
    func reload(items: [SectionItem], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        let existingItems = Set(snapshot.itemIdentifiers)
        assert(existingItems.isSuperset(of: items), "reload items not existing")
        let itemsToReload = items.filter { existingItems.contains($0) }
        snapshot.reloadItems(itemsToReload)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    /// Reconfigures cells instead of reloading them.
    /// Calling this method will not trigger any `UICollectionViewDataSource` methods.
    /// - Parameters:
    ///   - items: The SectionItem identifiers that need to be reconfigured.
    ///   - invalidateLayout: A boolean indicating whether to invalidate the layout of the items.
    ///   - configurer: A closure that allows you to configure each cell.
    ///     - If no closure is provided, the method attempts to cast the cell to `ViewConfigurable` and call `reconfigure`,
    ///       which updates the cell using the current `viewModel` without replacing it.
    ///     - `Important!` If you need to configure the cell with a new `viewModel`, you should provide a `configurer` block and update the cell in the block
    func reconfigure(items: [SectionItem],
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
    
    func delete(items: [SectionItem], animatingDifferences: Bool = false) {
        var snapshot = dataSource.snapshot()
        let existingItems = Set(snapshot.itemIdentifiers)
        assert(existingItems.isSuperset(of: items), "delete items not existing")
        let itemsToDelete = items.filter { existingItems.contains($0) }
        snapshot.deleteItems(itemsToDelete)
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
    
    func scroll(to item: SectionItem, position: UICollectionView.ScrollPosition, animated: Bool = false) {
        guard let indexPath = dataSource.indexPath(for: item) else { return }
        collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
    }
    
    func cellForItem(_ item: SectionItem) -> UICollectionViewCell? {
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
    
    func activateNextRespondableCell(section: Section, sectionItem: SectionItem) -> Bool {
        let snapshot = dataSource.snapshot()
        guard let indexPath = dataSource.indexPath(for: sectionItem) else {
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

    // MARK: - Section Loading

    /// Shows a loading indicator centered on the specified section
    func startLoading(for section: Section) {
        guard loadingView == nil else { return }

        let snapshot = dataSource.snapshot()
        guard let sectionIndex = snapshot.sectionIdentifiers.firstIndex(of: section) else { return }

        // Calculate section frame from layout attributes
        let itemCount = snapshot.numberOfItems(inSection: section)
        guard itemCount > 0 else { return }

        var sectionFrame = CGRect.null
        for itemIndex in 0..<itemCount {
            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            if let attributes = layout.layoutAttributesForItem(at: indexPath) {
                sectionFrame = sectionFrame.union(attributes.frame)
            }
        }

        guard !sectionFrame.isNull else { return }

        // Create and position loading indicator
        let spinner = LoadingSpinnerView(size: .medium)
        spinner.center = CGPoint(x: sectionFrame.midX, y: sectionFrame.midY)
        collectionView.addSubview(spinner)
        spinner.startAnimating()

        loadingView = spinner
        collectionView.isUserInteractionEnabled = false
    }

    /// Hides the loading indicator
    func stopLoading() {
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
        collectionView.isUserInteractionEnabled = true
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
    
    func dequeueReusableCell<T: UICollectionViewCell & ViewReusable>(_ cellClass: T.Type, for sectionItem: SectionItem, indexPath: IndexPath) -> T {
        register(cellClass)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
        cell.accessibilityIdentifier = String(describing: sectionItem.item)
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView & ViewReusable>(ofKind elementKind: String, viewClass: T.Type, indexPath: IndexPath) -> T {
        register(viewClass, forSupplementaryViewOfKind: elementKind)
        return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewClass.reuseIdentifier, for: indexPath) as! T
    }
}
