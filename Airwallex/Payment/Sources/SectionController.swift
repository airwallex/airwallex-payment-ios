//
//  SectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

/// this protocol is designed to work with `CollectionViewManager`
/// SectionController  define the behavior of a section in a UICollectionView
@MainActor protocol SectionController: SwiftLoggable  {
    associatedtype SectionType: Hashable, Sendable
    associatedtype ItemType: Hashable, Sendable
    
    /// CollectionViewContext provides a connection between your section controller
    /// and collectionView and it's dataSource
    /// it will be updated right after section controller being initialized
    /// use context to dequeue reusable cells/views and perform data updates
    var context: CollectionViewContext<SectionType, ItemType>! { get }
    
    /// this is the section identifier to work with UICollectionViewDiffableDataSource
    /// this must be unique
    var section: SectionType { get }
    
    /// this will to item identifier to work with UICollectionViewDiffableDataSource
    /// must be unique
    var items: [ItemType] { get }
    
    /// will be called by CollectionViewManager after section controlelr is initialized
    /// - Parameter context: contex
    func bind(context: CollectionViewContext<SectionType, ItemType>)
    
    /// this method will be called in the `cellProvider` of the `UICollectionViewDiffableDataSource`
    /// - Parameters:
    ///   - item: item identifier of the cell
    ///   - indexPath: index path of the cell
    /// - Returns: cell
    func cell(for item: ItemType, at indexPath: IndexPath) -> UICollectionViewCell
    
    /// this method will be called in the `sectionProvider` of the `UICollectionViewCompositionalLayout`
    /// - Parameter environment: layout environment
    /// - Returns: layout of the section
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    
    /// this will be called in the `supplementaryViewProvider` of `UICollectionViewDiffableDataSource`
    /// - Parameters:
    ///   - elementKind: element kind of the supplementary view
    ///   - indexPath: indexPath
    /// - Returns: supplementary views like header / footer
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView
    
    /// will be called when cell seletected
    /// - Parameters:
    ///   - item: item identifier for the selected cell
    ///   - indexPath: index path of the selected cell
    func collectionView(didSelectItem item: ItemType, at indexPath: IndexPath)
    
    /// this method will be called in `CollectionViewContext.performUpdates(...)`
    /// this will be the place for you to update items in your section controller
    func updateItemsIfNecessary()
}

extension SectionController {
    
    func updateItemsIfNecessary() {
        // do nothing by default
    }
    
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // provide supplementary view in you concrete SectionController
        fatalError()
    }
    
    func collectionView(didSelectItem itemIdentifier: ItemType, at indexPath: IndexPath) {
        // do nothing by default
    }
    
    func anySectionController() -> AnySectionController<SectionType, ItemType> {
        AnySectionController(self)
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", bundle: .payment, comment: ""), style: .cancel))
        context.viewController?.present(alert, animated: true)
    }
}

/// Type erasor for SectionController
class AnySectionController<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: SectionController {
    
    private let _cellProvider: (ItemType, IndexPath) -> UICollectionViewCell
    private let _layoutProvider: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    private let _supplementaryViewProvider: (String, IndexPath) -> UICollectionReusableView
    private let _didSelectHandler: (ItemType, IndexPath) -> Void
    private let _items: () -> [ItemType]
    private let _section: () -> SectionType
    private let _context: () -> CollectionViewContext<SectionType, ItemType>
    private let _bindContext: (CollectionViewContext<SectionType, ItemType>) -> Void
    private let _prepareItemUpdates: () -> Void
    
    var context: CollectionViewContext<SectionType, ItemType>! { _context() }
    var section: SectionType { _section() }
    var items: [ItemType] { _items() }
    
    init<SC: SectionController>(_ sectionController: SC) where SC.SectionType == SectionType, SC.ItemType == ItemType {
        self._cellProvider = sectionController.cell(for:at:)
        self._layoutProvider = sectionController.layout(environment:)
        self._supplementaryViewProvider = sectionController.supplementaryView(for:at:)
        self._didSelectHandler = sectionController.collectionView(didSelectItem:at:)
        self._bindContext = sectionController.bind(context:)
        self._items = { sectionController.items }
        self._section = { sectionController.section }
        self._context = { sectionController.context }
        self._prepareItemUpdates = { sectionController.updateItemsIfNecessary() }
    }
    
    func bind(context: CollectionViewContext<SectionType, ItemType>) {
        _bindContext(context)
    }
    
    func cell(for itemIdentifier: ItemType, at indexPath: IndexPath) -> UICollectionViewCell {
        return _cellProvider(itemIdentifier, indexPath)
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        return _layoutProvider(environment)
    }
    
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return _supplementaryViewProvider(elementKind, indexPath)
    }
    
    func collectionView(didSelectItem itemIdentifier: ItemType, at indexPath: IndexPath) {
        _didSelectHandler(itemIdentifier, indexPath)
    }
    
    func updateItemsIfNecessary() {
        _prepareItemUpdates()
    }
}
