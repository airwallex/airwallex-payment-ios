//
//  SectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

/// this protocol is designed to work with `CollectionViewManager`
/// SectionController  define the behavior of a section in a UICollectionView
@MainActor protocol SectionController: AnyObject {
    associatedtype SectionType: Hashable, Sendable
    associatedtype ItemType: Hashable, Sendable
    
    /// Type alias for the compound item type
    typealias SectionItem = CompoundItem<SectionType, ItemType>
    
    /// CollectionViewContext provides a connection between your section controller
    /// and collectionView and it's dataSource
    /// it will be updated right after section controller being initialized
    /// use context to dequeue reusable cells/views and perform data updates
    var context: CollectionViewContext<SectionType, ItemType>! { get }
    
    /// this is the section identifier to work with UICollectionViewDiffableDataSource
    /// this must be unique
    var section: SectionType { get }
    
    /// Raw items for this section. The CollectionViewManager will wrap these
    /// in SectionItem to ensure global uniqueness across all sections.
    var items: [ItemType] { get }
    
    /// will be called by CollectionViewManager after section controlelr is initialized
    /// - Parameter context: contex
    func bind(context: CollectionViewContext<SectionType, ItemType>)
    
    /// this method will be called in the `cellProvider` of the `UICollectionViewDiffableDataSource`
    /// - Parameters:
    ///   - sectionItem: the compound item identifier containing section and raw item
    ///   - indexPath: index path of the cell
    /// - Returns: cell
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell
    
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
    ///   - sectionItem: the compound item identifier for the selected cell
    ///   - indexPath: index path of the selected cell
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath)
    
    /// this method will be called in `CollectionViewContext.performUpdates(...)`
    /// this will be the place for you to update items in your section controller
    func updateItemsIfNecessary()
    
    /// Called just before a cell is displayed on the screen.
    /// - Parameters:
    ///   - cell: The `UICollectionViewCell` that is about to be displayed.
    ///   - sectionItem: The compound item identifier.
    ///   - indexPath: The `IndexPath` of the cell in the collection view.
    func willDisplay(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath)
    
    /// Called when a cell is removed from the screen (no longer visible).
    /// - Parameters:
    ///   - cell: The `UICollectionViewCell` that was displayed but is now being removed.
    ///   - sectionItem: The compound item identifier.
    ///   - indexPath: The `IndexPath` of the removed cell.
    func didEndDisplaying(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath)
    
    /// Called just before a supplementary view (e.g., header or footer) is displayed.
    /// - Parameters:
    ///   - supplementaryView: The `UICollectionReusableView` that is about to be displayed.
    ///   - indexPath: The `IndexPath` of the supplementary view in the collection view.
    func willDisplay(supplementaryView: UICollectionReusableView, at indexPath: IndexPath)
    
    /// Called when a supplementary view (e.g., header or footer) is removed from the screen.
    /// - Parameters:
    ///   - supplementaryView: The `UICollectionReusableView` that was displayed but is now being removed.
    ///   - indexPath: The `IndexPath` of the removed supplementary view.
    func didEndDisplaying(supplementaryView: UICollectionReusableView, at indexPath: IndexPath)
    
    /// Called just before the section managed by this section controller is displayed.
    func sectionWillDisplay()
    
    /// Called when the section managed by this section controller is no longer visible.
    func sectionDidEndDisplaying()
}
    
extension SectionController {
    
    /// Convenience method to create a SectionItem for this section
    func sectionItem(_ item: ItemType) -> SectionItem {
        SectionItem(section, item)
    }
    
    func updateItemsIfNecessary() {
        // do nothing by default
    }
    
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // provide supplementary view in you concrete SectionController
        fatalError()
    }
    
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
        // do nothing by default
    }
    
    func anySectionController() -> AnySectionController<SectionType, ItemType> {
        AnySectionController(self)
    }
    
    func willDisplay(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath) {
        // do nothing by default
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath) {
        // do nothing by default
    }
    
    func willDisplay(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        // do nothing by default
    }
    
    func didEndDisplaying(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        // do nothing by default
    }
    
    func sectionWillDisplay() {
        // do nothing by default
    }
    
    func sectionDidEndDisplaying() {
        // do nothing by default
    }
}
    
/// Type erasor for SectionController
class AnySectionController<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: SectionController {
    
    typealias SectionItem = CompoundItem<SectionType, ItemType>
    
    let embededSectionController: any SectionController
    private let _cellProvider: (SectionItem, IndexPath) -> UICollectionViewCell
    private let _layoutProvider: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    private let _supplementaryViewProvider: (String, IndexPath) -> UICollectionReusableView
    private let _didSelectHandler: (SectionItem, IndexPath) -> Void
    private let _items: () -> [ItemType]
    private let _section: () -> SectionType
    private let _context: () -> CollectionViewContext<SectionType, ItemType>
    private let _bindContext: (CollectionViewContext<SectionType, ItemType>) -> Void
    private let _updateItemsIfNecessary: () -> Void
    private let _willDisplayCell: (UICollectionViewCell, SectionItem, IndexPath) -> Void
    private let _didEndDisplayingCell: (UICollectionViewCell, SectionItem, IndexPath) -> Void
    private let _willDisplaySupplementaryView: (UICollectionReusableView, IndexPath) -> Void
    private let _didEndDisplayingSupplementaryView: (UICollectionReusableView, IndexPath) -> Void
    private let _sectionWillDisplay: () -> Void
    private let _sectionDidEndDisplaying: () -> Void
    
    var context: CollectionViewContext<SectionType, ItemType>! { _context() }
    var section: SectionType { _section() }
    var items: [ItemType] { _items() }
    
    init<SC: SectionController>(_ sectionController: SC) where SC.SectionType == SectionType, SC.ItemType == ItemType {
        self.embededSectionController = sectionController
        self._cellProvider = sectionController.cell(for:at:)
        self._layoutProvider = sectionController.layout(environment:)
        self._supplementaryViewProvider = sectionController.supplementaryView(for:at:)
        self._didSelectHandler = sectionController.collectionView(didSelectItem:at:)
        self._bindContext = sectionController.bind(context:)
        self._items = { sectionController.items }
        self._section = { sectionController.section }
        self._context = { sectionController.context }
        self._updateItemsIfNecessary = { sectionController.updateItemsIfNecessary() }
        self._willDisplayCell = sectionController.willDisplay(cell:sectionItem:at:)
        self._didEndDisplayingCell = sectionController.didEndDisplaying(cell:sectionItem:at:)
        self._willDisplaySupplementaryView = sectionController.willDisplay(supplementaryView:at:)
        self._didEndDisplayingSupplementaryView = sectionController.didEndDisplaying(supplementaryView:at:)
        self._sectionWillDisplay = sectionController.sectionWillDisplay
        self._sectionDidEndDisplaying = sectionController.sectionDidEndDisplaying
    }
    
    func bind(context: CollectionViewContext<SectionType, ItemType>) {
        _bindContext(context)
    }
    
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell {
        return _cellProvider(sectionItem, indexPath)
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        return _layoutProvider(environment)
    }
    
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return _supplementaryViewProvider(elementKind, indexPath)
    }
    
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
        _didSelectHandler(sectionItem, indexPath)
    }
    
    func updateItemsIfNecessary() {
        _updateItemsIfNecessary()
    }
    
    func willDisplay(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath) {
        _willDisplayCell(cell, sectionItem, indexPath)
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, sectionItem: SectionItem, at indexPath: IndexPath) {
        _didEndDisplayingCell(cell, sectionItem, indexPath)
    }
    
    func willDisplay(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        _willDisplaySupplementaryView(supplementaryView, indexPath)
    }
    
    func didEndDisplaying(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        _didEndDisplayingSupplementaryView(supplementaryView, indexPath)
    }
    
    func sectionWillDisplay() {
        _sectionWillDisplay()
    }
    
    func sectionDidEndDisplaying() {
        _sectionDidEndDisplaying()
    }
}
