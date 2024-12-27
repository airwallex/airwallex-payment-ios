//
//  NewCardPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine
import AirwallexRisk

class NewCardPaymentSectionController: SectionController {
    
    enum Item: String {
        case cardInfo
        case checkoutButton
    }
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String] {
        [ Item.cardInfo.rawValue, Item.checkoutButton.rawValue ]
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    private var methodType: AWXPaymentMethodType
    
    private var paymentSessionHandler: PaymentUISessionHandler?
    private var session: AWXSession {
        methodProvider.session
    }
    private let methodProvider: PaymentMethodProvider
    private let switchToConsentPaymentAction: () -> Void
    
    init(section: PaymentSectionType,
         methodType: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         switchToConsentPaymentAction: @escaping () -> Void) {
        assert(methodType.name == "card", "invalid method")
        self.section = section
        self.methodType = methodType
        self.methodProvider = methodProvider
        self.switchToConsentPaymentAction = switchToConsentPaymentAction
    }
    
    private lazy var cardInfoViewModel: CardInfoCollectorCellViewModel = {
        let viewModel = CardInfoCollectorCellViewModel(
            cardSchemes: methodType.cardSchemes,
            callbackForLayoutUpdate: { [weak self] in
                self?.context.invalidateLayout(for: [Item.cardInfo.rawValue], animated: false)
            }
        )
        return viewModel
    }()
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = Item(rawValue: item) else { fatalError("Invalid item") }
        switch item {
        case .cardInfo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardInfoCollectorCell.reuseIdentifier, for: indexPath) as! CardInfoCollectorCell
            cell.setup(cardInfoViewModel)
            return cell
        case .checkoutButton:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckoutButtonCell.reuseIdentifier, for: indexPath) as! CheckoutButtonCell
            cell.setup(CheckoutButtonCellViewModel(checkoutAction: checkout))
            return cell
        }
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerSectionHeader(CardPaymentSectionHeader.self)
        collectionView.registerReusableCell(CardInfoCollectorCell.self)
        collectionView.registerReusableCell(CheckoutButtonCell.self)
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
        section.interGroupSpacing = .spacing_16
        
        if !methodProvider.consents.isEmpty {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(32))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
        }
        return section
    }
    
    func supplementaryView(for collectionView: UICollectionView, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let viewModel = CardPaymentSectionHeaderViewModel(
            title: NSLocalizedString("Add new", comment: ""),
            actionTitle: "Keep using saved cards",
            buttonAction: { [weak self] in
                guard let self else { return }
                self.switchToConsentPaymentAction()
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
    
    private func checkout() {
        // TODO: checkout with billing info
        AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button")
        Risk.log(event: "click_payment_button", screen: "page_create_card")
        debugLog("Start payment. Intent ID: \(session.paymentIntentId())")
        do {
            let card = try cardInfoViewModel.createAndValidateCard()
            let handler = PaymentUISessionHandler(
                session: session,
                methodType: methodType,
                viewController: context.viewController!
            )
            handler?.startPayment(card: card)
            self.paymentSessionHandler = handler
        } catch {
            guard let message = error as? String else { return }
            showAlert(message)
            AWXAnalyticsLogger.shared().logAction(withName: "card_payment_validation", additionalInfo: ["message": message])
            debugLog("Payment failed. Intent ID: \(session.paymentIntentId()). Reason: \(message)")
        }
    }
    
}


