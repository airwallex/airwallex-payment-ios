//
//  SectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

@MainActor protocol SectionController: SwiftLoggable  {
    associatedtype SectionIdentifierType: Hashable, Sendable
    associatedtype ItemIdentifierType: Hashable, Sendable
    
    /// will be updated right after section controller being initialized
    var context: CollectionViewContext<SectionIdentifierType, ItemIdentifierType>! { get }
    
    var section: SectionIdentifierType { get }
    
    var items: [ItemIdentifierType] { get }
    
    func reload()
    
    func bind(context: CollectionViewContext<SectionIdentifierType, ItemIdentifierType>)
    
    func registerReusableViews(to collectionView: UICollectionView)
        
    func cell(for collectionView: UICollectionView, item: ItemIdentifierType, at indexPath: IndexPath) -> UICollectionViewCell
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection

    // with default implementation
    func supplementaryView(for collectionView: UICollectionView, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

extension SectionController {
    func reload() {}
    
    func supplementaryView(for collectionView: UICollectionView, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // provide supplementary view in you concrete SectionController
        fatalError()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // do nothing
    }
    
    func showTODO() {
        // TODO: Add new card
        let alert = UIAlertController(title: "TODO", message: "Not Implemented yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "DONE", style: .default))
        context.viewController?.present(alert, animated: true)
    }
    
    func anySectionController() -> AnySectionController<SectionIdentifierType, ItemIdentifierType> {
        AnySectionController(self)
    }
    
    func showAlert(_ message: String) {
        
    }
}

class AnySectionController<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: SectionController {
    
    private let _registerReusableViews: (UICollectionView) -> Void
    private let _cellProvider: (UICollectionView, ItemType, IndexPath) -> UICollectionViewCell
    private let _layoutProvider: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    private let _supplementaryViewProvider: (UICollectionView, String, IndexPath) -> UICollectionReusableView?
    private let _didSelectHandler: (UICollectionView, IndexPath) -> Void
    private let _items: () -> [ItemType]
    private let _section: () -> SectionType
    private let _context: () -> CollectionViewContext<SectionType, ItemType>
    private let _bindContext: (CollectionViewContext<SectionType, ItemType>) -> Void
    private let _reload: () -> Void
    
    var context: CollectionViewContext<SectionType, ItemType>! { _context() }
    var section: SectionType { _section() }
    var items: [ItemType] { _items() }
    
    init<SC: SectionController>(_ sectionController: SC) where SC.SectionIdentifierType == SectionType, SC.ItemIdentifierType == ItemType {
        self._registerReusableViews = sectionController.registerReusableViews
        self._cellProvider = sectionController.cell(for:item:at:)
        self._layoutProvider = sectionController.layout(environment:)
        self._supplementaryViewProvider = sectionController.supplementaryView(for:ofKind:at:)
        self._didSelectHandler = sectionController.collectionView(_:didSelectItemAt:)
        self._bindContext = sectionController.bind(context:)
        self._items = { sectionController.items }
        self._section = { sectionController.section }
        self._context = { sectionController.context }
        self._reload = { sectionController.reload() }
    }
    
    func bind(context: CollectionViewContext<SectionType, ItemType>) {
        _bindContext(context)
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        _registerReusableViews(collectionView)
    }
    
    func cell(for collectionView: UICollectionView, item: ItemType, at indexPath: IndexPath) -> UICollectionViewCell {
        return _cellProvider(collectionView, item, indexPath)
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        return _layoutProvider(environment)
    }
    
    func supplementaryView(for collectionView: UICollectionView, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView? {
        return _supplementaryViewProvider(collectionView, elementKind, indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _didSelectHandler(collectionView, indexPath)
    }
    
    func reload() {
        _reload()
    }
}
