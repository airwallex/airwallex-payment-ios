//
//  MethodListSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

class PaymentMethodTabSectionController: SectionController {
    
    private var session: AWXSession {
        methodProvider.session
    }
    
    private var selectedMethod: String
    private let methodProvider: PaymentMethodProvider
    
    private var methodTypes: [AWXPaymentMethodType]
    private let imageLoader: ImageLoader
    
    init(methodProvider: PaymentMethodProvider,
         imageLoader: ImageLoader) {
        self.methodProvider = methodProvider
        self.methodTypes = methodProvider.methods.filter { $0.name != AWXApplePayKey }
        self.selectedMethod = methodProvider.selectedMethod?.name ?? ""
        self.imageLoader = imageLoader
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
            itemIdentifier: methodType.name,
            name: methodType.displayName,
            imageURL: methodType.resources.logoURL,
            isSelected: itemIdentifier == selectedMethod,
            imageLoader: imageLoader,
            cardBrands: []
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
        section.contentInsets = .init(horizontal: 16).bottom(8)
        section.interGroupSpacing = 8
        return section
    }

    func collectionView(didSelectItem itemIdentifier: String, at indexPath: IndexPath) {
        guard let selected = methodTypes[safe: indexPath.item] else {
            assert(false, "invalid index")
            return
        }
        guard selected.name != selectedMethod else {
            context.endEditing()
            return
        }
        AnalyticsLogger.log(action: .selectPayment, extraInfo: [.paymentMethod: itemIdentifier])
        
        let itemsToReload = [ selected.name, selectedMethod ]
        selectedMethod = selected.name
        methodProvider.selectedMethod = selected
        context.reload(items: itemsToReload)
    }
    
    func updateItemsIfNecessary() {
        methodTypes = methodProvider.methods.filter { $0.name != AWXApplePayKey }
        selectedMethod = methodProvider.selectedMethod?.name ?? ""
    }
}
