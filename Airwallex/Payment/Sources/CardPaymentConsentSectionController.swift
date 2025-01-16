//
//  CardPaymentConsentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardPaymentConsentSectionController: SectionController {
    
    private enum Items {
        static let checkoutButton: String = "checkoutButton"
        static let cvcField: String = "cvcField"
    }
    
    private enum Mode {
        case list
        case payment
    }
    
    private(set)var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.cardPaymentConsent
    
    var items: [String] {
        if let selectedConsent {
            return [
                selectedConsent.id,
                Items.cvcField,
                Items.checkoutButton
            ]
        } else {
            return consents.map { $0.id }
        }
    }
    
    private var consents: [AWXPaymentConsent]
    
    private var session: AWXSession {
        methodProvider.session
    }
    
    let methodProvider: PaymentMethodProvider
    
    private let addNewCardAction: () -> Void
    
    private var paymentSessionHandler: PaymentUISessionHandler?
    
    private var selectedConsent: AWXPaymentConsent?
    private var cvcConfigurer: InfoCollectorCellConfiguring?
    private var mode: Mode {
        selectedConsent == nil ? .list : .payment
    }
    
    init(methodProvider: PaymentMethodProvider,
         addNewCardAction: @escaping () -> Void) {
        self.methodProvider = methodProvider
        self.addNewCardAction = addNewCardAction
        self.consents = methodProvider.consents
    }
    
    // MARK: - SectionController
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case Items.checkoutButton:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckoutButtonCell.reuseIdentifier, for: indexPath) as! CheckoutButtonCell
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCollectorCell.reuseIdentifier, for: indexPath) as! InfoCollectorCell
            if let cvcConfigurer {
                cell.setup(cvcConfigurer)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardConsentCell.reuseIdentifier,
                for: indexPath
            ) as! CardConsentCell
            
            guard let consent = selectedConsent ?? consents[safe: indexPath.item],
                  let card = consent.paymentMethod?.card,
                  let brand = card.brand else {
                assert(false, "invalid card consent")
                return cell
            }
            
            var image: UIImage? = nil
            if let cardBrand = AWXCardValidator.shared().brand(forCardName: brand) {
                image = UIImage.image(for: cardBrand.type)
            }
                        
            var viewModel: CardConsentCellViewModel
            if let selectedConsent {
                viewModel = CardConsentCellViewModel(
                    image: image,
                    text: "\(brand.capitalized) •••• \(card.last4 ?? "")",
                    highlightable: false,
                    actionTitle: NSLocalizedString("Change", bundle: .payment, comment: "unselect card payment consent and back to consent list"),
                    actionIcon: nil,
                    buttonAction: { [weak self] in
                        guard let self else { return }
                        self.selectedConsent = nil
                        self.cvcConfigurer = nil
                        self.context.performUpdates(section, forceReload: true, animatingDifferences: false)
                    }
                )
            } else {
                viewModel = CardConsentCellViewModel(
                    image: image,
                    text: "\(brand.capitalized) •••• \(card.last4 ?? "")",
                    highlightable: true,
                    actionIcon: UIImage(systemName: "ellipsis")?.rotate(degrees: 90),
                    buttonAction: { [weak self] in
                        self?.showAlertForDelete(consent, indexPath: indexPath)
                    }
                )
            }
            cell.setup(viewModel)
            return cell
        }
    }
    
    func supplementaryView(for collectionView: UICollectionView, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: CardPaymentSectionHeader.reuseIdentifier, for: indexPath) as! CardPaymentSectionHeader
        let viewModel = CardPaymentSectionHeaderViewModel(
            title: NSLocalizedString("Choose a card", comment: ""),
            actionTitle: NSLocalizedString("Add new", bundle: .payment, comment: ""),
            buttonAction: { [weak self] in
                guard let self else { return }
                self.addNewCardAction()
            }
        )
        header.setup(viewModel)
        return header
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch mode {
        case .list:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(56)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(horizontal: .spacing_16)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(32))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        case .payment:
            let consentSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(32)
            )
            let consentItem = NSCollectionLayoutItem(layoutSize: consentSize)
            consentItem.contentInsets = .init().trailing(.spacing_16)
            let cvcSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(40)
            )
            let cvcItem = NSCollectionLayoutItem(layoutSize: cvcSize)
            cvcItem.contentInsets = .init().horizontal(.spacing_16)
            let group1 = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(100)
                ),
                subitems: [consentItem, cvcItem]
            )
            group1.interItemSpacing = NSCollectionLayoutSpacing.fixed(16)
            
            let buttonSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(52)
            )
            let buttonItem = NSCollectionLayoutItem(layoutSize: buttonSize)
            buttonItem.contentInsets = .init().horizontal(.spacing_16)
            let group2 = NSCollectionLayoutGroup.vertical(
                layoutSize: buttonSize,
                subitems: [group1, buttonItem]
            )
            group2.interItemSpacing = .fixed(24)
            let section = NSCollectionLayoutSection(group: group2)
            return section
        }
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerReusableCell(CardConsentCell.self)
        collectionView.registerSectionHeader(CardPaymentSectionHeader.self)
        collectionView.registerReusableCell(CheckoutButtonCell.self)
        collectionView.registerReusableCell(InfoCollectorCell.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mode == .payment {
            // do nothing if consent is already selected
            return
        }
        
        guard let consent = consents[safe: indexPath.item],
              let viewController = context.viewController else {
            assert(false, "view controller not found")
            return
        }
        
        if consent.paymentMethod?.card?.numberType == "PAN" {
            selectedConsent = consent
            let brand = AWXCardValidator.shared().brand(forCardName: consent.paymentMethod?.card?.brand ?? "")
            let cvcLength = AWXCardValidator.cvcLength(for: brand?.type ?? .unknown)
            cvcConfigurer = InfoCollectorTextFieldViewModel(
                textFieldType: .CVC,
                placeholder: "CVC",
                customTextModifier: { input in
                    guard let input, !input.isEmpty else {
                        return (nil, nil, false)
                    }
                    let text = String(input.filterIllegalCharacters(in: .decimalDigits.inverted).prefix(cvcLength))
                    let shouldTriggerNextField = text.count == cvcLength
                    return (text, nil, shouldTriggerNextField)
                },
                customInputValidator: { text in
                    try AWXCardValidator.validate(cvc: text, requiredLength: cvcLength)
                },
                triggerLayoutUpdate: { [weak self] in
                    self?.context.invalidateLayout(for: [consent.id], animated: false)
                }
            )
            context.performUpdates(section, forceReload: true)
        } else {
            //  CVC not required, checkout directly
            checkout(consent: consent)
        }
    }
    
    func updateItemsIfNecessary() {
        consents = methodProvider.consents
    }
}
 
private extension CardPaymentConsentSectionController {
    // actions
    func showAlertForDelete(_ consent: AWXPaymentConsent, indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("Would you like to delete this card?", bundle: .payment, comment: ""),
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("Delete", comment: "delete consent"),
            style: .destructive) { [weak self] _ in
                guard let self else { return }
                self.context.viewController?.startAnimating()
                Task {
                    do {
                        try await self.methodProvider.disable(consent: consent)
                        self.context.delete(items: [ consent.id ])
                        self.debugLog("remove consent successfully. ID: \(consent.id)")
                    } catch {
                        self.showAlert(error.localizedDescription)
                        self.debugLog("removing consent failed. ID: \(consent.id)")
                    }
                    self.context.viewController?.stopAnimating()
                }
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", bundle: .payment, comment: "cancel delete consent"),
            style: .cancel
        )
        alert.addAction(cancelAction)
        context.viewController?.present(alert, animated: true)
    }
    
    func checkout(consent: AWXPaymentConsent) {
        guard let viewController = context.viewController else {
            assert(false, "view controller not found")
            return
        }
        
        if let cvcConfigurer {
            cvcConfigurer.handleDidEndEditing()
            guard cvcConfigurer.isValid else {
                let message = cvcConfigurer.errorHint ?? NSLocalizedString("Invalid CVC / CVV", bundle: .payment, comment: "")
                showAlert(message)
                return
            }
            consent.paymentMethod?.card?.cvc = cvcConfigurer.text
        }
        paymentSessionHandler = PaymentUISessionHandler(
            session: session,
            paymentConsent: consent,
            viewController: viewController
        )
        paymentSessionHandler?.startPayment()
    }
}
