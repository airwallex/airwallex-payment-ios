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
            reloadData: reloadData
        )
    }
    
    func reloadData(animatingDifferences: Bool = true) {
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
            }
            controller?.reload()
            let items = controller?.items ?? []
            snapshot.appendItems(items, toSection: section)
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

class CollectionViewContext<Section: Hashable & Sendable, Item: Hashable & Sendable> {
    private(set) weak var viewController: AWXViewController?
    private weak var collectionView: UICollectionView!
    private weak var layout: UICollectionViewCompositionalLayout!
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, Item>
    private var _reloadData: (Bool) -> Void
    
    init(viewController: AWXViewController,
         collectionView: UICollectionView,
         layout: UICollectionViewCompositionalLayout,
         dataSource: UICollectionViewDiffableDataSource<Section, Item>,
         reloadData: @escaping (Bool) -> Void) {
        self.viewController = viewController
        self.collectionView = collectionView
        self.layout = layout
        self.dataSource = dataSource
        self._reloadData = reloadData
    }
    
    func currentSnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        return dataSource.snapshot()
    }
    
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>) {
        dataSource.apply(snapshot)
    }
    
    func invalidateLayout(for items: [Item], animated: Bool = true) {
        var indexPaths = [IndexPath]()
        for item in items {
            guard let indexPath = dataSource.indexPath(for: item) else { continue }
            indexPaths.append(indexPath)
        }
        invalidateLayout(at: indexPaths, animated: animated)
    }
    
    func invalidateLayout(at indexPaths: [IndexPath], animated: Bool = true) {
        let invalidationContext = UICollectionViewLayoutInvalidationContext()
        invalidationContext.invalidateItems(at: indexPaths)
        layout.invalidateLayout(with: invalidationContext)
        if animated {
            collectionView.performBatchUpdates(nil)
        }
    }
    
    func reload(sections: [Section], animatingDifferences: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections(sections)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func reload(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func delete(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    func reloadData(animatingDifferences: Bool = true) {
        _reloadData(animatingDifferences)
    }
}