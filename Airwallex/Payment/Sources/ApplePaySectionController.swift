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
    private var paymentSessionHandler: PaymentSessionHandler?
    private(set) var items: [String]
    
    init(session: AWXSession, methodType: AWXPaymentMethodType) {
        self.session = session
        self.methodType = methodType
        self.items = [ methodType.name ]
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = context.dequeueReusableCell(ApplePayCell.self, for: itemIdentifier, indexPath: indexPath)
        let viewModel = ApplePayViewModel { [weak self] in
            guard let self , let viewController = self.context.viewController else { return }
            AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button", additionalInfo: ["payment_method": methodType.name])
            self.paymentSessionHandler = PaymentSessionHandler(
                session: self.session,
                viewController: viewController,
                methodType: methodType
            )
            self.paymentSessionHandler?.startApplePay()
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
        section.contentInsets = .init(horizontal: 16)
        return section
    }
}
