//
//  NewCardPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

class NewCardPaymentSectionController: SectionController {
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    var section: PaymentSectionType
    
    var items: [String] = ["card_info"]
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    private var methodType: AWXPaymentMethodType
    
    init(section: PaymentSectionType,
         methodType: AWXPaymentMethodType) {
        self.section = section
        self.methodType = methodType
    }
    
    private lazy var cardInfoViewModel: PaymentCardInfoCellViewModel = {
        let viewModel = PaymentCardInfoCellViewModel(
            cardSchemes: methodType.cardSchemes,
            callbackForLayoutUpdate: { [weak self] in
                guard let self, let context = self.context else { return }
            
                guard let indexPath = context.dataSource.indexPath(for: "card_info") else { return }
                let invalidationContext = UICollectionViewLayoutInvalidationContext()
                invalidationContext.invalidateItems(at: [indexPath])
                context.layout.invalidateLayout(with: invalidationContext)
                context.collectionView.performBatchUpdates(nil)
            }
        )
        return viewModel
    }()
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCardInfoCell.reuseIdentifier, for: indexPath) as! PaymentCardInfoCell
        cell.setup(cardInfoViewModel)
        return cell
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.register(
            CardPaymentSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CardPaymentSectionHeader.reuseIdentifier
        )
        
        collectionView.register(
            PaymentCardInfoCell.self,
            forCellWithReuseIdentifier: PaymentCardInfoCell.reuseIdentifier
        )
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: .spacing_16, leading: .spacing_16, bottom: .spacing_16, trailing: .spacing_16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(32))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func supplementaryView(for collectionView: UICollectionView, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let viewModel = CardPaymentSectionHeaderViewModel(
            title: NSLocalizedString("Add new", comment: ""),
            actionTitle: "Keep using saved cards",
            buttonAction: { [weak self] in
                self?.showTODO()
            }
        )
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: CardPaymentSectionHeader.reuseIdentifier,
            for: indexPath
        ) as! CardPaymentSectionHeader
        view.setup(viewModel)
        return view
    }
    
}
