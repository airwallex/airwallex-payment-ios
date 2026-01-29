//
//  MethodListSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif
    
class PaymentMethodTabSectionController: SectionController {
    typealias SectionItem = CompoundItem<PaymentSectionType, String>
    private var session: AWXSession {
        methodProvider.session
    }
    
    private var selectedMethod: String
    private let methodProvider: PaymentMethodProvider
    private let paymentUIContext: PaymentSheetUIContext
    private var methodTypes: [AWXPaymentMethodType]

    init(methodProvider: PaymentMethodProvider,
         paymentUIContext: PaymentSheetUIContext) {
        self.methodProvider = methodProvider
        self.paymentUIContext = paymentUIContext
        self.methodTypes = methodProvider.methods.filter { $0.name != AWXApplePayKey }
        self.selectedMethod = methodProvider.selectedMethod?.name ?? ""
    }
    
    // MARK: - SectionController
    var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.methodList
    
    var items: [String] {
        methodTypes
            .filter { $0.name != AWXApplePayKey }
            .map { $0.name }
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = context.dequeueReusableCell(PaymentMethodCell.self, for: sectionItem, indexPath: indexPath)
        guard let methodType = methodTypes[safe: indexPath.item] else {
            assert(false, "index out of bounds")
            return cell
        }
        let viewModel = PaymentMethodCellViewModel(
            itemIdentifier: methodType.name,
            name: methodType.displayName,
            imageURL: methodType.resources.logoURL,
            isSelected: methodType.name == selectedMethod,
            imageLoader: paymentUIContext.imageLoader,
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
        section.contentInsets = .init(horizontal: paymentUIContext.isEmbedded ? 0 : 16).bottom(8)
        section.interGroupSpacing = 8
        return section
    }
    
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
        guard let selected = methodTypes[safe: indexPath.item] else {
            assert(false, "invalid index")
            return
        }
        guard selected.name != selectedMethod else {
            context.endEditing()
            return
        }
        AnalyticsLogger.log(action: .selectPayment, extraInfo: [.paymentMethod: selected.name])
    
        let itemsToReload = [
            self.sectionItem(selected.name),
            self.sectionItem(selectedMethod)
        ]
        selectedMethod = selected.name
        methodProvider.selectedMethod = selected
        context.reload(items: itemsToReload)
    }
    
    func updateItemsIfNecessary() {
        methodTypes = methodProvider.methods.filter { $0.name != AWXApplePayKey }
        selectedMethod = methodProvider.selectedMethod?.name ?? ""
    }
}
