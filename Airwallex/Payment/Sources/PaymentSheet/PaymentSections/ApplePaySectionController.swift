//
//  ApplePaySectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Core)
import Core
#endif

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
            AnalyticsLogger.log(action: .tapPayButton, extraInfo: [.paymentMethod: methodType.name])
            do {
                self.paymentSessionHandler = PaymentSessionHandler(
                    session: self.session,
                    viewController: viewController,
                    paymentResultDelegate: AWXUIContext.shared().delegate,
                    methodType: methodType
                )
                try self.paymentSessionHandler?.confirmApplePay(cancelPaymentOnDismiss: false)
            } catch {
                self.context.viewController?.showAlert(message: error.localizedDescription)
            }
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
    
    func sectionWillDisplay() {
        AnalyticsLogger.log(paymentMethodView: .applePay)
    }
}
