//
//  CollectionViewManager.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/18.
//  Copyright © 2024 Airwallex. All rights reserved.
//

//
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
    
    init(viewController: AWXViewController,
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
                      let sectionIndex = self.sections[safe: index],
                      let controller = self.sectionController(for: sectionIndex) else {
                    assert(false, "invalid section index")
                    return nil
                }
                return controller.layout(environment: environment)
            },
            configuration: listConfiguration
        )
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        
        if let boundaryItems {
            for item in boundaryItems {
                collectionView.register(item.reusableView, forSupplementaryViewOfKind: item.elementKind)
            }
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource<SectionType, ItemType>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
                guard let self, let sectionIndex = self.sections[safe: indexPath.section],
                      let sectionController = self.sectionControllers[sectionIndex] else {
                    assert(false, "invalid section index")
                    return UICollectionViewCell()
                }
                return sectionController.cell(for: collectionView, item: itemIdentifier, at: indexPath)
            }
        )
        
        diffableDataSource.supplementaryViewProvider = {[weak self] (collectionView, elementKind, indexPath) in
            if elementKind == "collection-header-element-kind" {
                return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: LabelHeader.reuseIdentifier, for: indexPath)
            }
            guard let self,
                  let section = self.sections[safe: indexPath.section],
                  let sectionController = self.sectionControllers[section] else {
                assert(false, "UI not consistance with data source")
                return UICollectionReusableView()
            }
            
            return sectionController.supplementaryView(for: collectionView, ofKind: elementKind, at: indexPath)
        }
        self.context = CollectionViewContext(
            viewController: viewController,
            collectionView: collectionView,
            layout: layout,
            dataSource: diffableDataSource,
            reloadSectionData: performUpdates,
            reloadData: performUpdates
        )
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
                sectionController.registerReusableViews(to: collectionView)
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
        guard let controller = sectionController(for: section) else { return }
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
    
    func sectionController(for section: SectionType) -> AnySectionController<SectionType, ItemType>? {
        sectionControllers[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = sections[safe: indexPath.section],
              let controller = sectionControllers[section] else { return }
        controller.collectionView(collectionView, didSelectItemAt: indexPath)
    }
}

class CollectionViewContext<Section: Hashable & Sendable, Item: Hashable & Sendable>: SwiftLoggable {
    private(set) weak var viewController: AWXViewController?
    private weak var collectionView: UICollectionView!
    private weak var layout: UICollectionViewCompositionalLayout!
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, Item>
    private var _performUpdates: (Bool, Bool) -> Void
    private var _performUpdatesForSection: (Section, Bool, Bool, Bool) -> Void
    
    init(viewController: AWXViewController,
         collectionView: UICollectionView,
         layout: UICollectionViewCompositionalLayout,
         dataSource: UICollectionViewDiffableDataSource<Section, Item>,
         reloadSectionData: @escaping (Section, Bool, Bool, Bool) -> Void,
         reloadData: @escaping (Bool, Bool) -> Void) {
        self.viewController = viewController
        self.collectionView = collectionView
        self.layout = layout
        self.dataSource = dataSource
        self._performUpdates = reloadData
        self._performUpdatesForSection = reloadSectionData
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
}
