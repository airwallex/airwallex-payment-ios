//
//  AccordionSectionController.swift
//  Payment
//
//  Created by Weiping Li on 2025/4/3.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Combine
#if canImport(AirwallexCore)
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif
#endif

class AccordionSectionController: SectionController  {
    
    static let separatorElementKind = "acordian-folded-item-separator"
    static let backgroundElementKind = "acordian-folded-section-background"
    
    enum Position {
        case top
        case bottom
    }
    
    private var methodProvider: PaymentMethodProvider
    private var viewModels = [PaymentMethodCellViewModel]()
    private let imageLoader: ImageLoader
    let position: Position
    private let separatorUpdatePublisher = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(position: Position,
         methodProvider: PaymentMethodProvider,
         imageLoader: ImageLoader) {
        self.position = position
        self.section = PaymentSectionType.accordion(position)
        self.methodProvider = methodProvider
        self.imageLoader = imageLoader
        updateItemsIfNecessary()
        separatorUpdatePublisher
            .throttle(for: .milliseconds(1), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.updateCellSeparatorStatus()
            }
            .store(in: &cancellables)
    }
    
    let section: PaymentSectionType
    
    var items: [String] {
        viewModels.map { $0.itemIdentifier }
    }
    
    var context: CollectionViewContext<PaymentSectionType, String>!
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cellClass = (item == AWXCardKey ? AccordionCardMethodCell.self : AccordionPaymentMethodCell.self)
        let cell = context.dequeueReusableCell(cellClass, for: item, indexPath: indexPath)
        if let viewModel = viewModels[safe: indexPath.item] {
            cell.setup(viewModel)
        }
        return cell
    }
    
    func collectionView(didSelectItem item: String, at indexPath: IndexPath) {
        methodProvider.selectPaymentMethod(byName: item)
    }
            
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // Layout for cell separator
        let separatorSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(1)
        )
        let separatorAnchor = NSCollectionLayoutAnchor(edges: .bottom)
        let separator = NSCollectionLayoutSupplementaryItem(
            layoutSize: separatorSize,
            elementKind: Self.separatorElementKind,
            containerAnchor: separatorAnchor
        )
        // Layout for item
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize, supplementaryItems: [separator])
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
        // Layout for decoration - rounded corner
        context.register(RoundedCornerDecorationView.self, forDecorationViewOfKind: Self.backgroundElementKind)
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: Self.backgroundElementKind)
        sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
        section.decorationItems = [sectionBackgroundDecoration]
        return section
    }
    
    func supplementaryView(for elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch elementKind {
        case Self.separatorElementKind:
            let view = context.dequeueReusableSupplementaryView(
                ofKind: elementKind,
                viewClass: CellSeparator.self,
                indexPath: indexPath
            )
            let itemCount = context.currentSnapshot().numberOfItems(inSection: section)
            view.isHidden = itemCount == indexPath.item - 1
            return view
        default:
            fatalError("unexpected elementKind: \(elementKind)")
        }
    }
    
    func updateItemsIfNecessary() {
        guard case PaymentSectionType.accordion(let position) = section else {
            viewModels = []
            assert(false, "invalid section tycpe")
            return
        }
        
        viewModels = methodProvider.methodsForAccordionPosition(position).map { methodType in
            PaymentMethodCellViewModel(
                itemIdentifier: methodType.name,
                name: methodType.displayName,
                imageURL: methodType.resources.logoURL,
                isSelected: false,
                imageLoader: imageLoader,
                cardBrands: methodType.cardSchemes.map { $0.brandType }
            )
        }
    }
    
    func willDisplay(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        separatorUpdatePublisher.send()
    }
    
    func didEndDisplaying(supplementaryView: UICollectionReusableView, at indexPath: IndexPath) {
        separatorUpdatePublisher.send()
    }
    
    private func updateCellSeparatorStatus() {
        let snapshot = context.currentSnapshot()
        guard let sectionIndex = snapshot.indexOfSection(section) else {
            return
        }
        let itemCount = snapshot.numberOfItems(inSection: section)
        for itemIndex in 0..<itemCount {
            let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            guard let supplementaryView = context.supplementaryView(forElementKind: Self.separatorElementKind, at: indexPath) else {
                continue
            }
            supplementaryView.isHidden = (indexPath.item == itemCount - 1)
        }
    }
}

extension PaymentMethodProvider {
    func methodsForAccordionPosition(_ position: AccordionSectionController.Position) -> [AWXPaymentMethodType] {
        guard let selectedMethod,
              let index = methods.firstIndex(where: { $0.name == selectedMethod.name }) else {
            switch position {
            case .top:
                return methods
            case .bottom:
                return []
            }
        }
        let methodSlice = (position == .top) ? methods[..<index] : methods[(index+1)...]
        return Array(methodSlice.filter { $0.name != AWXApplePayKey })
    }
}
