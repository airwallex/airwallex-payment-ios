//
//  ApplePaySectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class ApplePaySectionController: SectionController {
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!

    let section = PaymentSectionType.applePay
    let session: AWXSession
    let methodType: AWXPaymentMethodType
    let paymentSessionHandler: PaymentUISessionHandler?
    private(set) var items: [String]
    
    init(session: AWXSession, methodType: AWXPaymentMethodType, viewController: AWXViewController) {
        self.session = session
        self.methodType = methodType
        self.items = [ methodType.name ]
        self.paymentSessionHandler = PaymentUISessionHandler(
            session: session,
            methodType: methodType,
            viewController: viewController
        )
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerReusableCell(ApplePayCell.self)
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ApplePayCell.reuseIdentifier,
            for: indexPath
        ) as! ApplePayCell
        let viewModel = ApplePayViewModel { [weak self] in
            guard let handler = self?.paymentSessionHandler else { return }
            handler.startPayment()
        }
        
        cell.setup(viewModel)
        return cell
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 24, leading: 16, bottom: 16, trailing: 16)
        return section
    }
}
