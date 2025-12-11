//
//  CardPaymentConsentSectionController.swift
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

class CardPaymentConsentSectionController: SectionController {
    
    static let subType = "consent"
    
    enum Items: RawRepresentable {
        /// for accordion layout
        case accordionKey
        /// for addNewCardToggle
        case addNewCardToggle
        /// checkout button for payment mode
        case checkoutButton
        /// cvc field if required for payment mode
        case cvcField
        /// selected consent
        case selectedConsent

        var rawValue: String {
            "\(PaymentSectionType.cardPaymentConsent)-\(String(describing: self))"
        }

        init?(rawValue: String) {
            switch rawValue {
            case Items.accordionKey.rawValue: self = .accordionKey
            case Items.addNewCardToggle.rawValue: self = .addNewCardToggle
            case Items.checkoutButton.rawValue: self = .checkoutButton
            case Items.cvcField.rawValue: self = .cvcField
            case Items.selectedConsent.rawValue: self = .selectedConsent
            default: return nil
            }
        }
    }
    
    enum Mode {
        /// display all consents in a list
        case consentList
        /// display selected consent for checkout
        case consentPayment
    }
    private var consents: [AWXPaymentConsent]
    
    private var session: AWXSession {
        methodProvider.session
    }
    
    let methodProvider: PaymentMethodProvider
    
    private let addNewCardAction: () -> Void
    
    private var paymentSessionHandler: PaymentSessionHandler?
    
    private var selectedConsent: AWXPaymentConsent?
    private var cvcConfigurer: InfoCollectorTextFieldViewModel?
    var mode: Mode {
        selectedConsent == nil ? .consentList : .consentPayment
    }
    private let layout: AWXUIContext.PaymentLayout
    
    private lazy var viewModelForAccordionKey = PaymentMethodCellViewModel(
        itemIdentifier: Items.accordionKey.rawValue,
        name: methodType.displayName,
        imageURL: methodType.resources.logoURL,
        isSelected: true,
        imageLoader: imageLoader,
        cardBrands: []
    )
    
    private lazy var viewModelForConsentToggle = CardPaymentToggleCellViewModel(
        title: NSLocalizedString("Choose a card", bundle: .paymentSheet, comment: "consent section - choose a saved card"),
        actionTitle: NSLocalizedString("Add new", bundle: .paymentSheet, comment: "consent section - add a new card"),
        buttonAction: { [weak self] in
            guard let self else { return }
            self.addNewCardAction()
            
            AnalyticsLogger.log(
                action: .selectPayment,
                extraInfo: [
                    .paymentMethod: AWXCardKey,
                    .subtype: NewCardPaymentSectionController.subType
                ]
            )
        }
    )
    
    private let methodType: AWXPaymentMethodType
    private let imageLoader: ImageLoader
    
    init(methodType: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         layout: AWXUIContext.PaymentLayout,
         imageLoader: ImageLoader,
         addNewCardAction: @escaping () -> Void) {
        self.methodType = methodType
        self.imageLoader = imageLoader
        self.methodProvider = methodProvider
        self.addNewCardAction = addNewCardAction
        self.consents = methodProvider.consents.filter { $0.paymentMethod != nil }
        if consents.count == 1,
           let consent = consents.first {
            self.selectedConsent = consent
        }
        self.layout = layout
    }
    
    // MARK: - SectionController
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.cardPaymentConsent
    
    var items: [String] {
        var items = [String]()
        if layout == .accordion {
            items.append(Items.accordionKey.rawValue)
        }

        if let selectedConsent {
            // payment mode
            items.append(Items.selectedConsent.rawValue)
            if selectedConsent.paymentMethod?.card?.numberType == AWXCard.NumberType.PAN {
                items.append(Items.cvcField.rawValue)
            }
            items.append(Items.checkoutButton.rawValue)
        } else {
            // list mode
            items.append(Items.addNewCardToggle.rawValue)
            items += consents.map { $0.id }
        }
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        switch itemIdentifier {
        case Items.accordionKey.rawValue:
            let cell = context.dequeueReusableCell(AccordionSelectedMethodCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(viewModelForAccordionKey)
            return cell
        case Items.addNewCardToggle.rawValue:
            let cell = context.dequeueReusableCell(CardPaymentToggleCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(viewModelForConsentToggle)
            return cell
        case Items.checkoutButton.rawValue:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: itemIdentifier, indexPath: indexPath)
            let viewModel = CheckoutButtonCellViewModel(shouldShowPayAsCta: !(session is AWXRecurringSession)) { [weak self] in
                guard let self, let selectedConsent else {
                    assert(false, "selected consent not found")
                    return
                }
                self.checkout(consent: selectedConsent)
            }
            cell.setup(viewModel)
            return cell
        case Items.cvcField.rawValue:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: itemIdentifier, indexPath: indexPath)
            guard let selectedConsent else {
                assert(false, "expected selected consent")
                return cell
            }
            if let cvcConfigurer {
                cell.setup(cvcConfigurer)
            } else {
                let cvcConfigurer = createCVCConfigurer(consent: selectedConsent)
                self.cvcConfigurer = cvcConfigurer
                cell.setup(cvcConfigurer)
            }
            return cell
        case Items.selectedConsent.rawValue:
            let cell = context.dequeueReusableCell(CardSelectedConsentCell.self, for: itemIdentifier, indexPath: indexPath)
            if let consentID = selectedConsent?.id,
               let viewModel = viewModelForConsent(consentID: consentID) {
                cell.setup(viewModel)
            }
            cell.accessibilityIdentifier = "consentSelected"
            return cell
        default:
            // consent list
            let cell = context.dequeueReusableCell(CardConsentCell.self, for: itemIdentifier, indexPath: indexPath)
            if let viewModel = viewModelForConsent(consentID: itemIdentifier) {
                cell.setup(viewModel)
            }
            if let consent = consents.first(where: { $0.id == itemIdentifier}) {
                if consent.isCITConsent {
                    cell.accessibilityIdentifier = "consentListed-cit"
                } else {
                    cell.accessibilityIdentifier = "consentListed-mit"
                }
            }
            return cell
        }
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(32)
        )
        
        switch mode {
        case .consentList:
            let listItem = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [listItem]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            switch layout {
            case .accordion:
                section.contentInsets = .init(top: 16, leading: 40, bottom: 24, trailing: 40)
                // Layout for decoration - rounded corner
                let elementKind = AccordionSectionController.backgroundElementKind
                context.register(
                    RoundedCornerDecorationView.self,
                    forDecorationViewOfKind: elementKind
                )
                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
                sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
                section.decorationItems = [sectionBackgroundDecoration]
            case .tab:
                section.contentInsets = .init(horizontal: 16)
            }
            return section
        case .consentPayment:
            let items: [NSCollectionLayoutItem] = (1..<items.count).map { _ in
                NSCollectionLayoutItem(layoutSize: itemSize)
            }
            
            let innerGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(100)
                ),
                subitems: items
            )
            innerGroup.interItemSpacing = .fixed(16)
            
            let buttonSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(52)
            )
            let buttonItem = NSCollectionLayoutItem(layoutSize: buttonSize)
            
            let outerGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(300)
                ),
                subitems: [innerGroup, buttonItem]
            )
            outerGroup.interItemSpacing = .fixed(24)
            
            let section = NSCollectionLayoutSection(group: outerGroup)
            switch layout {
            case .accordion:
                section.contentInsets = .init(top: 16, leading: 40, bottom: 32, trailing: 40)
                // Layout for decoration - rounded corner
                let elementKind = AccordionSectionController.backgroundElementKind
                context.register(
                    RoundedCornerDecorationView.self,
                    forDecorationViewOfKind: elementKind
                )
                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
                sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
                section.decorationItems = [sectionBackgroundDecoration]
            case .tab:
                section.contentInsets = .init(horizontal: 16)
            }
            return section
        }
    }
    
    func collectionView(didSelectItem itemIdentifier: String, at indexPath: IndexPath) {
        guard mode == .consentList else {
            // do nothing if consent is already selected
            // user needs to select change button in section header to go back to consent list
            context.endEditing()
            return
        }
        
        guard ![Items.accordionKey.rawValue, Items.addNewCardToggle.rawValue].contains(itemIdentifier) else {
            context.endEditing()
            return
        }
        guard let consent = consents.first(where: { $0.id == itemIdentifier }) ,
              context.viewController != nil else {
            assert(false, "view controller not found")
            return
        }
        AnalyticsLogger.log(
            action: .selectPayment,
            extraInfo: [
                .paymentMethod: AWXCardKey,
                .subtype: Self.subType,
                .consentId: consent.id
            ]
        )
        
        selectedConsent = consent
        context.performUpdates(section, forceReload: true)
        
        RiskLogger.log(.showConsent, screen: .consent)
    }
    
    func updateItemsIfNecessary() {
        consents = methodProvider.consents.filter { $0.paymentMethod != nil }
    }
    
    func sectionWillDisplay() {
        AnalyticsLogger.log(
            paymentMethodView: .card,
            extraInfo: [
                .subtype: Self.subType
            ]
        )
    }
    
    private func createCVCConfigurer(consent: AWXPaymentConsent) -> InfoCollectorCellViewModel<String> {
        let validator = CardCVCValidator(cardName: consent.paymentMethod?.card?.brand ?? "")
        let viewModel = InfoCollectorCellViewModel(
            itemIdentifier: Items.cvcField.rawValue,
            textFieldType: .CVC,
            placeholder: NSLocalizedString("CVC", bundle: .paymentSheet, comment: "consent section - cvc field placeholder"),
            customInputFormatter: validator,
            customInputValidator: validator,
            editingEventObserver: BeginEditingEventObserver {
                RiskLogger.log(.inputCardCVC, screen: .consent)
            },
            cellReconfigureHandler: { [weak self] in
                self?.context.reconfigure(items: [$0], invalidateLayout: $1)
            }
        )
        return viewModel
    }
    
    private func viewModelForConsent(consentID: String) -> CardConsentCellViewModel? {
        guard let consent = consents.first(where: { $0.id == consentID }),
              let card = consent.paymentMethod?.card,
              let brand = card.brand else {
            return nil
        }
        
        var image: UIImage? = nil
        if let cardBrand = AWXCardValidator.shared().brand(forCardName: brand) {
            image = UIImage.image(for: cardBrand.type)
        }
        
        let consentTitle = "\(brand.capitalized) •••• \(card.last4 ?? "")"
        if selectedConsent?.id == consentID {
            return CardConsentCellViewModel(
                image: image,
                text: consentTitle,
                highlightable: false,
                actionTitle: NSLocalizedString("Change", bundle: .paymentSheet, comment: "consent section - unselect consent and go back to consent list"),
                actionIcon: nil,
                buttonAction: { [weak self] in
                    guard let self else { return }
                    self.selectedConsent = nil
                    self.cvcConfigurer = nil
                    self.context.performUpdates(section, forceReload: true, animatingDifferences: false)
                }
            )
        } else {
            let actionIconColor: UIColor = consent.isCITConsent ? .awxColor(.iconLink) : .awxColor(.iconDisabled)
            return CardConsentCellViewModel(
                image: image,
                text: consentTitle,
                highlightable: true,
                actionTitle: nil,
                actionIcon: UIImage(systemName: "ellipsis")?
                    .rotate(degrees: 90)?
                    .withTintColor(actionIconColor, renderingMode: .alwaysOriginal),
                buttonAction: { [weak self] in
                    if consent.isCITConsent {
                        self?.showAlertForDeleteCITConsent(consent, consentDescription: consentTitle)
                    } else {
                        self?.showAlertForDeleteMITConsent(consent)
                    }
                }
            )
        }
    }
}
 
private extension CardPaymentConsentSectionController {
    // actions
    func showAlertForDeleteCITConsent(_ consent: AWXPaymentConsent, consentDescription: String) {
        let title = NSLocalizedString("Remove %@?", bundle: .paymentSheet, comment: "consent section - alert title for delete a consent")
        let alert = AWXAlertController(
            title: String(format: title, consentDescription),
            message: NSLocalizedString("This option will be permanently removed from your saved payment methods.", bundle: .paymentSheet, comment: "consent section - alert message for delete a consent"),
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("Remove", bundle: .paymentSheet, comment: "consent section - alert confirm button to remove a consent"),
            style: .destructive) { [weak self] _ in
                guard let self else { return }
                self.context.viewController?.startLoading()
                Task {
                    do {
                        try await self.methodProvider.disable(consent: consent)
                        debugLog("remove consent successfully. ID: \(consent.id)")
                    } catch {
                        self.context.viewController?.showAlert(message: error.localizedDescription)
                        debugLog("removing consent failed. ID: \(consent.id)")
                    }
                    self.context.viewController?.stopLoading()
                }
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", bundle: .paymentSheet, comment: "consent section - alert cancel button to delete a consent"),
            style: .cancel
        )
        alert.addAction(cancelAction)
        context.viewController?.present(alert, animated: true)
    }
    
    func showAlertForDeleteMITConsent(_ consent: AWXPaymentConsent) {
        do {
            guard let token = AWXAPIClientConfiguration.shared().clientSecret else {
                throw "clientSecret not found".asError()
            }
            let payload = try token.payloadOfJWT()
            guard let merchantName = payload["business_name"] as? String else {
                throw "business name not found in token \(token)".asError()
            }
            let message = String(format: NSLocalizedString("This card is used for other payments you've set up with %@. Please contact %@ to update the payment method for these payments before removing this card.", bundle: .paymentSheet, comment: "alert message for delete MIT consent"), merchantName, merchantName)
            let alert = AWXAlertController(
                title: nil,
                message: message,
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", bundle: .paymentSheet, comment: "consent section - alert cancel button to delete a consent"),
                style: .cancel
            )
            alert.addAction(cancelAction)
            context.viewController?.present(alert, animated: true)
        } catch {
            AnalyticsLogger.log(errorName: "JWT decoding error", errorMessage: error.localizedDescription)
        }
    }
    
    func checkout(consent: AWXPaymentConsent) {
        context.endEditing()
        guard let viewController = context.viewController else {
            assert(false, "view controller not found")
            return
        }
        AnalyticsLogger.log(
            action: .tapPayButton,
            extraInfo: [
                .paymentMethod: AWXCardKey,
                .subtype: Self.subType,
                .consentId: consent.id
            ]
        )
        if let cvcConfigurer {
            cvcConfigurer.handleDidEndEditing(reconfigureStrategy: .onValidationChange)
            do {
                try cvcConfigurer.validate()
                consent.paymentMethod?.card?.cvc = cvcConfigurer.text
            } catch {
                context.viewController?.showAlert(message: error.localizedDescription)
                return
            }
        }
        if mode == .consentPayment {
            RiskLogger.log(.clickPaymentButton, screen: .consent)
        }
        do {
            paymentSessionHandler = PaymentSessionHandler(
                session: session,
                viewController: viewController,
                paymentResultDelegate: AWXUIContext.shared.delegate,
                dismissAction: { completion in
                    AWXUIContext.shared.dismissAction?(completion)
                    // clear dismissAction block here so the user cancel detection
                    // in AWXPaymentViewController.deinit() can work as expected
                    AWXUIContext.shared.dismissAction = nil
                }
            )
            try paymentSessionHandler?.confirmConsentPayment(with: consent)
        } catch {
            context.viewController?.showAlert(message: error.localizedDescription)
        }
    }
}
