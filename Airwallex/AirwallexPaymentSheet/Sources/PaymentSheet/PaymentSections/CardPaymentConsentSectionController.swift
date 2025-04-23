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
    
    enum Items {
        /// for accordion layout
        static let accordionKey = "consentAccordionKey"
        /// for addNewCardToggle
        static let addNewCardToggle = "addNewCardToggle"
        /// checkout button for payment mode
        static let checkoutButton: String = "checkoutButton"
        /// cvc field if required for payment mode
        static let cvcField: String = "cvcField"
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
        itemIdentifier: Items.accordionKey,
        name: methodType.displayName,
        imageURL: methodType.resources.logoURL,
        isSelected: true,
        imageLoader: imageLoader,
        cardBrands: []
    )
    
    private lazy var viewModelForConsentToggle = CardPaymentToggleCellViewModel(
        title: NSLocalizedString("Choose a card", comment: ""),
        actionTitle: NSLocalizedString("Add new", bundle: .paymentSheet, comment: ""),
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
           let consent = consents.first,
           consent.paymentMethod?.card?.numberType == AWXCard.NumberType.PAN {
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
            items.append(Items.accordionKey)
        }
        
        if let selectedConsent {
            // payment mode
            items += [
                selectedConsent.id,
                Items.cvcField,
                Items.checkoutButton
            ]
        } else {
            // list mode
            items.append(Items.addNewCardToggle)
            items += consents.map { $0.id }
        }
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        switch itemIdentifier {
        case Items.accordionKey:
            let cell = context.dequeueReusableCell(AccordionSelectedMethodCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(viewModelForAccordionKey)
            return cell
        case Items.addNewCardToggle:
            let cell = context.dequeueReusableCell(CardPaymentToggleCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(viewModelForConsentToggle)
            return cell
        case Items.checkoutButton:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: itemIdentifier, indexPath: indexPath)
            let viewModel = CheckoutButtonCellViewModel { [weak self] in
                guard let self, let selectedConsent else {
                    assert(false, "selected consent not found")
                    return
                }
                self.checkout(consent: selectedConsent)
            }
            cell.setup(viewModel)
            return cell
        case Items.cvcField:
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
        default:
            
            guard let consent = selectedConsent ?? consents.first(where: { $0.id == itemIdentifier }),
                  let card = consent.paymentMethod?.card,
                  let brand = card.brand else {
                assert(false, "invalid card consent")
                return UICollectionViewCell()
            }
            
            var image: UIImage? = nil
            if let cardBrand = AWXCardValidator.shared().brand(forCardName: brand) {
                image = UIImage.image(for: cardBrand.type)
            }
                        
            var viewModel: CardConsentCellViewModel
            var cell: CardConsentCell
            if selectedConsent != nil {
                cell = context.dequeueReusableCell(CardSelectedConsentCell.self, for: itemIdentifier, indexPath: indexPath)
                viewModel = CardConsentCellViewModel(
                    image: image,
                    text: "\(brand.capitalized) •••• \(card.last4 ?? "")",
                    highlightable: false,
                    actionTitle: NSLocalizedString("Change", bundle: .paymentSheet, comment: "unselect card payment consent and back to consent list"),
                    actionIcon: nil,
                    buttonAction: { [weak self] in
                        guard let self else { return }
                        self.selectedConsent = nil
                        self.cvcConfigurer = nil
                        self.context.performUpdates(section, forceReload: true, animatingDifferences: false)
                    }
                )
            } else {
                cell = context.dequeueReusableCell(CardConsentCell.self, for: itemIdentifier, indexPath: indexPath)
                let consentTitle = "\(brand.capitalized) •••• \(card.last4 ?? "")"
                viewModel = CardConsentCellViewModel(
                    image: image,
                    text: consentTitle,
                    highlightable: true,
                    actionTitle: nil,
                    actionIcon: UIImage(systemName: "ellipsis")?
                        .rotate(degrees: 90)?
                        .withTintColor(.awxColor(.iconLink), renderingMode: .alwaysOriginal),
                    buttonAction: { [weak self] in
                        self?.showAlertForDelete(consent, consentDescription: consentTitle)
                    }
                )
            }
            cell.setup(viewModel)
            return cell
        }
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(32)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        switch layout {
        case .tab:
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = .init(horizontal: 16)
            return section
        case .accordion:
            let section: NSCollectionLayoutSection
            if mode == .consentList {
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 16
                section.contentInsets = .init(top: 16, leading: 40, bottom: 24, trailing: 40)
            } else {
                let items: [NSCollectionLayoutItem] = (0..<3).map { _ in
                    NSCollectionLayoutItem(layoutSize: itemSize)
                }
                
                let buttonSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(52)
                )
                let buttonItem = NSCollectionLayoutItem(layoutSize: buttonSize)
                
                let innerGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(100)
                    ),
                    subitems: items
                )
                innerGroup.interItemSpacing = .fixed(16)
                
                let outerGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(120)
                    ),
                    subitems: [innerGroup, buttonItem]
                )
                outerGroup.interItemSpacing = .fixed(24)
                section = NSCollectionLayoutSection(group: outerGroup)
                section.contentInsets = .init(top: 16, leading: 40, bottom: 32, trailing: 40)
            }
            
            // Layout for decoration - rounded corner
            let elementKind = AccordionSectionController.backgroundElementKind
            context.register(
                RoundedCornerDecorationView.self,
                forDecorationViewOfKind: elementKind
            )
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
            sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
            section.decorationItems = [sectionBackgroundDecoration]
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
        
        guard ![Items.accordionKey, Items.addNewCardToggle].contains(itemIdentifier) else {
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
        
        if consent.paymentMethod?.card?.numberType == AWXCard.NumberType.PAN {
            selectedConsent = consent
            context.performUpdates(section, forceReload: true)
            
            RiskLogger.log(.showConsent, screen: .consent)
        } else {
            //  CVC not required, checkout directly
            checkout(consent: consent)
        }
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
            itemIdentifier: Items.cvcField,
            textFieldType: .CVC,
            placeholder: NSLocalizedString("CVC", bundle: .paymentSheet, comment: ""),
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
}
 
private extension CardPaymentConsentSectionController {
    // actions
    func showAlertForDelete(_ consent: AWXPaymentConsent, consentDescription: String) {
        let title = "Remove %@?"
        let alert = AWXAlertController(
            title: String(format: NSLocalizedString(title, bundle: .paymentSheet, comment: "alert for delete consent"), consentDescription),
            message: NSLocalizedString("This option will be permanently removed from your saved payment methods.", bundle: .paymentSheet, comment: "message for delete consent"),
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("Remove", bundle: .paymentSheet, comment: "confirm delete consent"),
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
            title: NSLocalizedString("Cancel", bundle: .paymentSheet, comment: "cancel delete consent"),
            style: .cancel
        )
        alert.addAction(cancelAction)
        context.viewController?.present(alert, animated: true)
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
            cvcConfigurer.handleDidEndEditing(reconfigurePolicy: .automatic)
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
