//
//  SectionDisplayHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit

@MainActor
class SectionDisplayHandler<SectionType: Hashable & Sendable, ItemType: Hashable & Sendable>: NSObject {
    
    private class ItemHolder: RawRepresentable {
        let rawValue: ItemType
        required init(rawValue: ItemType) {
            self.rawValue = rawValue
        }
    }
    
    private(set) lazy var counter = NSCountedSet()
    
    private var viewToSectionMap = NSMapTable<UICollectionReusableView, AnySectionController<SectionType, ItemType>>(
        keyOptions: [.objectPointerPersonality, .strongMemory],
        valueOptions: [.strongMemory]
    )
    
    private var viewToItemMap = NSMapTable<UICollectionViewCell, ItemHolder>(
        keyOptions: [.objectPointerPersonality, .strongMemory],
        valueOptions: [.strongMemory]
    )
    
    func mapView(_ view: UICollectionReusableView,
                 to sectionController: AnySectionController<SectionType, ItemType>) {
        viewToSectionMap.setObject(sectionController, forKey: view)
    }
    
    func mapCell(_ cell: UICollectionViewCell,
                 to sectionController: AnySectionController<SectionType, ItemType>,
                 itemIdentifier: ItemType) {
        viewToSectionMap.setObject(sectionController, forKey: cell)
        viewToItemMap.setObject(ItemHolder(rawValue: itemIdentifier), forKey: cell)
    }
    
    func unmap(_ view: UICollectionReusableView) {
        viewToSectionMap.removeObject(forKey: view)
        if let view = view as? UICollectionViewCell {
            viewToItemMap.removeObject(forKey: view)
        }
    }
    
    func sectionControllerByView(_ view: UICollectionReusableView) -> AnySectionController<SectionType, ItemType>? {
        viewToSectionMap.object(forKey: view)
    }
    
    func itemIdentifierByCell(_ cell: UICollectionViewCell) -> ItemType? {
        viewToItemMap.object(forKey: cell)?.rawValue
    }
    
    // MARK: -
    func willDisplay(cell: UICollectionViewCell,
                     for sectionController: AnySectionController<SectionType, ItemType>,
                     itemIdentifier: ItemType,
                     indexPath: IndexPath) {
        mapCell(cell, to: sectionController, itemIdentifier: itemIdentifier)
        sectionController.willDisplay(
            cell: cell,
            itemIdentifier: itemIdentifier,
            at: indexPath
        )
        
        count(willDisplay: cell, for: sectionController, indexPath: indexPath)
    }
    
    func didEndDisplaying(cell: UICollectionViewCell, indexPath: IndexPath) {
        guard let sectionController = sectionControllerByView(cell),
            let itemIdentifier = itemIdentifierByCell(cell) else {
                assert(false, "mapping breaks")
            unmap(cell)
            return
        }
        unmap(cell)
        sectionController.didEndDisplaying(
            cell: cell,
            itemIdentifier: itemIdentifier,
            at: indexPath
        )
        count(didEndDisplaying:cell, for: sectionController, indexPath: indexPath)
    }
    
    func willDisplay(supplementaryView: UICollectionReusableView,
                     for sectionController: AnySectionController<SectionType, ItemType>,
                     indexPath: IndexPath) {
        mapView(supplementaryView, to: sectionController)
        sectionController.willDisplay(supplementaryView: supplementaryView, at: indexPath)
        count(willDisplay: supplementaryView, for: sectionController, indexPath: indexPath)
    }
    
    func didEndDisplaying(supplementaryView: UICollectionReusableView, indexPath: IndexPath) {
        guard let sectionController = sectionControllerByView(supplementaryView) else {
            assert(false, "mapping breaks")
            unmap(supplementaryView)
            return
        }
        unmap(supplementaryView)
        sectionController.didEndDisplaying(supplementaryView: supplementaryView, at: indexPath)
        count(didEndDisplaying: supplementaryView, for: sectionController, indexPath: indexPath)
    }
}

private extension SectionDisplayHandler {
    func count(willDisplay reusableView: UICollectionReusableView,
               for sectionController: AnySectionController<SectionType, ItemType>,
               indexPath: IndexPath) {
        if counter.count(for: sectionController) == 0 {
            sectionController.sectionWillDisplay()
        }
        counter.add(sectionController)
    }
    
    func count(didEndDisplaying reusableView: UICollectionReusableView,
               for sectionController: AnySectionController<SectionType, ItemType>,
               indexPath: IndexPath) {
        DispatchQueue.main.async {
            // defer couting to next runloop to avoid unnecessary
            // end displaying/ will display callback when reload section
            self.counter.remove(sectionController)
            if self.counter.count(for: sectionController) == 0 {
                sectionController.sectionDidEndDisplaying()
            }
        }
    }
}
