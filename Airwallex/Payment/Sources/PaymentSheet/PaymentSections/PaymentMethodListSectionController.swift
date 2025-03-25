//
//  MethodListSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(Core)
import Core
#endif

class PaymentMethodListSectionController: SectionController {
    
    private var session: AWXSession {
        methodProvider.session
    }
    
    private var selectedMethod: String
    private let methodProvider: PaymentMethodProvider
    
    private var methodTypes: [AWXPaymentMethodType]
    private var imageLoader = ImageLoader()
    
    init(methodProvider: PaymentMethodProvider) {
        self.methodProvider = methodProvider
        methodTypes = methodProvider.methods.filter { $0.name != AWXApplePayKey }
        selectedMethod = methodProvider.selectedMethod?.name ?? ""
    }
    
    // MARK: - SectionController
    var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.methodList
    
    var items: [String]  {
        methodTypes.compactMap { $0.name != AWXApplePayKey ? $0.name : nil }
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = context.dequeueReusableCell(PaymentMethodCell.self, for: itemIdentifier, indexPath: indexPath)
        guard let methodType = methodTypes[safe: indexPath.item] else {
            assert(false, "index out of bounds")
            return cell
        }
        let viewModel = PaymentMethodCellViewModel(
            name: methodType.displayName,
            imageURL: methodType.resources.logoURL,
            isSelected: itemIdentifier == selectedMethod,
            imageLoader: imageLoader
        )
        cell.setup(viewModel)
        return cell
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .absolute(92),
            heightDimension: .absolute(70)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 24, leading: 16, bottom: 8, trailing: 16)
        section.interGroupSpacing = 8
        
        if methodProvider.isApplePayAvailable {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(22)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
        }
        return section
    }
    
    func supplementaryView(for elementKind: String,
                           at indexPath: IndexPath) -> UICollectionReusableView {
        context.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            viewClass: PaymentMethodListSeparator.self,
            indexPath: indexPath
        )
    }

    func collectionView(didSelectItem itemIdentifier: String, at indexPath: IndexPath) {
        guard let selected = methodTypes[safe: indexPath.item] else {
            assert(false, "invalid index")
            return
        }
        guard selected.name != selectedMethod else {
            debugLog("select same method")
            return
        }
        AnalyticsLogger.log(action: .selectPayment, extraInfo: [.paymentMethod: itemIdentifier])
        
        var itemsToReload = [ selected.name, selectedMethod ]
        selectedMethod = selected.name
        methodProvider.selectedMethod = selected
        context.reload(items: itemsToReload)
    }
    
    func updateItemsIfNecessary() {
        methodTypes = methodProvider.methods.filter { $0.name != AWXApplePayKey }
        selectedMethod = methodProvider.selectedMethod?.name ?? ""
    }
}
