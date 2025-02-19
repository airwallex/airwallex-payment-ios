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

class NewCardPaymentSectionController: NSObject, SectionController {
    
    // TODO: what about other fields? email, first/last name, phone number
    enum Item: String {
        case cardInfo
        case checkoutButton
        // display this item only when session is AWXOneOffSession && has customerId
        case saveCardToggle
        case billingInfo
    }
    
    private var methodType: AWXPaymentMethodType
    
    private var paymentSessionHandler: PaymentUISessionHandler?
    private var session: AWXSession {
        methodProvider.session
    }
    private let methodProvider: PaymentMethodProvider
    private let switchToConsentPaymentAction: () -> Void
    private lazy var shouldSaveCard = false
    private var shouldReuseShippingAddress = true
    private let validator: AWXCardValidator
    
    private lazy var cardInfoViewModel: CardInfoCollectorCellViewModel = {
        let viewModel = CardInfoCollectorCellViewModel(
            cardSchemes: methodType.cardSchemes,
            callbackForLayoutUpdate: { [weak self] in
                self?.context.invalidateLayout(for: [Item.cardInfo.rawValue], animated: false)
            }
        )
        return viewModel
    }()
    
    private lazy var billingInfoViewModel: BillingInfoCellViewModel = {
        let viewModel = BillingInfoCellViewModel(
            shippingInfo: session.billing,
            reusingShippingInfo: shouldReuseShippingAddress,
            countrySelectionHandler: { [weak self] in
                self?.triggerCountrySelection()
            },
            triggerLayoutUpdate: { [weak self] in
                self?.context.invalidateLayout(for: [Item.billingInfo.rawValue], animated: false)
            },
            toggleReuseSelection: { [weak self] in
                guard let self else { return }
                self.shouldReuseShippingAddress.toggle()
                self.toggleReuseBillingAddress(shouldReuseShippingAddress)
            }
        )
        return viewModel
    }()
    
    init(cardPaymentMethod: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         switchToConsentPaymentAction: @escaping () -> Void) {
        assert(cardPaymentMethod.name == AWXCardKey, "invalid method")
        self.methodType = cardPaymentMethod
        self.methodProvider = methodProvider
        self.switchToConsentPaymentAction = switchToConsentPaymentAction
        self.validator = AWXCardValidator(cardPaymentMethod.cardSchemes)
        self.shouldReuseShippingAddress = methodProvider.session.billing != nil
    }
    
    // MARK: - SectionController
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.cardPaymentNew
    
    var items: [String] {
        var items = [
            Item.cardInfo.rawValue,
        ]
        
        if session.isBillingInformationRequired {
            items.append(Item.billingInfo.rawValue)
        }
        
        if supportCardSaving {
            items.append(Item.saveCardToggle.rawValue)
        }
        
        items.append(Item.checkoutButton.rawValue)
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
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
        case .saveCardToggle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckBoxCell.reuseIdentifier, for: indexPath) as! CheckBoxCell
            let viewModel = CheckBoxCellViewModel(
                isSelected: shouldSaveCard,
                title: nil,
                boxInfo: NSLocalizedString("Save my card for future payments", comment: "checkbox in checkout view"),
                selectionDidChanged: { [weak self] isSelected in
                    self?.shouldSaveCard = isSelected
                }
            )
            cell.setup(viewModel)
            return cell
        case .billingInfo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BillingInfoCell.reuseIdentifier, for: indexPath) as! BillingInfoCell
            cell.setup(billingInfoViewModel)
            return cell
        }
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerSectionHeader(CardPaymentSectionHeader.self)
        collectionView.registerReusableCell(CardInfoCollectorCell.self)
        collectionView.registerReusableCell(CheckoutButtonCell.self)
        collectionView.registerReusableCell(CheckBoxCell.self)
        collectionView.registerReusableCell(BillingInfoCell.self)
        collectionView.registerReusableCell(InfoCollectorCell.self)
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(horizontal: .spacing_16)
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
}

private extension NewCardPaymentSectionController {
    
    var supportCardSaving: Bool {
        guard let session = session as? AWXOneOffSession,
           let customerId = session.customerId(),
           !customerId.isEmpty else {
            return false
        }
        return true
    }
    
    func checkout() {
        AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button")
        Risk.log(event: "click_payment_button", screen: "page_create_card")
        debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")
        do {
            let card = cardInfoViewModel.cardFromCollectedInfo()
            try validator.validate(card: card)
            
            var billingInfo: AWXPlaceDetails?
            if session.isBillingInformationRequired {
                billingInfo = billingInfoViewModel.billingFromCollectedInfo()
                let error = billingInfo?.validate()
                if let error {
                    throw error
                }
            }
            
            let handler = PaymentUISessionHandler(
                session: session,
                methodType: methodType,
                viewController: context.viewController!
            )
            guard let handler = PaymentUISessionHandler(
                session: session,
                methodType: methodType,
                viewController: context.viewController!
            ) else {
                throw "Invalid payment method"
            }
            handler.startPayment(card: card, billing: billingInfo, saveCard: shouldSaveCard)
            paymentSessionHandler = handler
        } catch {
            cardInfoViewModel.updateValidStatusForCheckout()
            billingInfoViewModel.updateValidStatusForCheckout()
            context.reload(sections: [section])
            guard let message = error as? String else { return }
            showAlert(message)
            AWXAnalyticsLogger.shared().logAction(withName: "card_payment_validation", additionalInfo: ["message": message])
            debugLog("Payment failed. Intent ID: \(session.paymentIntentId() ?? ""). Reason: \(message)")
        }
    }
    
    func triggerCountrySelection() {
        let controller = AWXCountryListViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.country = billingInfoViewModel.countryConfigurer.country
        let nav = UINavigationController(rootViewController: controller)
        context.viewController?.present(nav, animated: true)
    }
    
    func toggleReuseBillingAddress(_ reuseBillingAddress: Bool) {
        shouldReuseShippingAddress = reuseBillingAddress
        billingInfoViewModel = BillingInfoCellViewModel(
            shippingInfo: session.billing,
            reusingShippingInfo: reuseBillingAddress,
            countrySelectionHandler: { [weak self] in
                self?.triggerCountrySelection()
            },
            triggerLayoutUpdate: { [weak self] in
                self?.context.invalidateLayout(for: [Item.billingInfo.rawValue], animated: false)
            },
            toggleReuseSelection: { [weak self] in
                guard let self else { return }
                self.shouldReuseShippingAddress.toggle()
                self.toggleReuseBillingAddress(self.shouldReuseShippingAddress)
            }
        )
        context.reload(items: [ Item.billingInfo.rawValue ])
    }
}

extension NewCardPaymentSectionController: AWXCountryListViewControllerDelegate {
    func countryListViewController(_ controller: AWXCountryListViewController, didSelect country: AWXCountry) {
        controller.dismiss(animated: true)
        billingInfoViewModel.countryConfigurer.country = country
        context.reload(items: [ Item.billingInfo.rawValue ])
    }
}

