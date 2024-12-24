//
//  MethodListSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class PaymentMethodListSectionController: SectionController {
    var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String]  {
        methodTypes.map { $0.name }
    }
    
    let session: AWXSession
    private var paymentSessionHandler: PaymentUISessionHandler?
    private var selectedMethod: AWXPaymentMethodType?
    let methodTypes: [AWXPaymentMethodType]
    
    init(section: PaymentSectionType, methodTypes: [AWXPaymentMethodType], session: AWXSession) {
        self.section = section
        self.methodTypes = methodTypes
        self.selectedMethod = methodTypes.first
        self.session = session
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.register(
            PaymentMethodCell.self,
            forCellWithReuseIdentifier: PaymentMethodCell.reuseIdentifier
        )
        collectionView.register(
            PaymentMethodListSeparator.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PaymentMethodListSeparator.reuseIdentifier
        )
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaymentMethodCell.reuseIdentifier,
            for: indexPath
        ) as! PaymentMethodCell
        
        let methodType = methodTypes[indexPath.item]
        let viewModel = PaymentMethodCellViewModel(
            name: methodType.displayName,
            imageURL: methodType.resources.logoURL,
            isSelected: item == self.selectedMethod?.name
        )
        cell.setup(viewModel)
        return cell
    }
    
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(92),
            heightDimension: .absolute(70)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 24, leading: 16, bottom: 24, trailing: 16)
        section.interGroupSpacing = 8
        
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
        return section
    }
    
    func supplementaryView(for collectionView: UICollectionView,
                           ofKind elementKind: String,
                           at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: PaymentMethodListSeparator.reuseIdentifier,
            for: indexPath
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMethod = methodTypes[indexPath.item]
        var snapshot = context.currentSnapshot()
        let items = snapshot.itemIdentifiers(inSection: section)
        snapshot.reloadItems(items)
        context.applySnapshot(snapshot)
    }
}
