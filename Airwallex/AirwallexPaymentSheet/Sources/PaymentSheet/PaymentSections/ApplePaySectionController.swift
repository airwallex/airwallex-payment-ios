//
//  ApplePaySectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
#endif

class ApplePaySectionController: SectionController {
    
    let session: AWXSession
    let methodType: AWXPaymentMethodType
    private var paymentSessionHandler: PaymentSessionHandler?
    private let methodProvider: PaymentMethodProvider
    
    init(session: AWXSession,
         methodType: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider) {
        self.session = session
        self.methodType = methodType
        self.items = [ methodType.name ]
        self.methodProvider = methodProvider
    }
    
    let section = PaymentSectionType.applePay
    
    private(set) var items: [String]
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
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
    
    func supplementaryView(for elementKind: String,
                           at indexPath: IndexPath) -> UICollectionReusableView {
        context.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            viewClass: PaymentMethodListSeparator.self,
            indexPath: indexPath
        )
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
        var contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
        if methodProvider.methods.contains(where: { $0.name != AWXApplePayKey }) {
            contentInsets.bottom = 16
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(22)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [header]
        }
        section.contentInsets = contentInsets
        return section
    }
    
    func sectionWillDisplay() {
        AnalyticsLogger.log(paymentMethodView: .applePay)
    }
}
