//
//  CardPaymentConsentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

class CardPaymentConsentSectionController: SectionController {
    
    private(set)var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String] {
        consents.map { $0.id }
    }
    
    private(set) var consents: [AWXPaymentConsent]
    
    let session: AWXSession
    
    let methodProvider: PaymentMethodProvider
    
    private let addNewCardAction: () -> Void
    
    init(session: AWXSession,
         section: PaymentSectionType,
         methodProvider: PaymentMethodProvider,
         addNewCardAction: @escaping () -> Void) {
        self.session = session
        self.section = section
        self.consents = methodProvider.consents
        self.methodProvider = methodProvider
        self.addNewCardAction = addNewCardAction
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CardConsentCell.reuseIdentifier,
            for: indexPath
        ) as! CardConsentCell
        let consent = consents[indexPath.item]
        guard let card = consent.paymentMethod?.card,
              let brand = card.brand else {
            assert(false, "invalid card consent")
            return cell
        }
        
        var image: UIImage? = nil
        if let cardBrand = AWXCardValidator.shared().brand(forCardName: brand) {
            image = UIImage.image(for: cardBrand.type)
        }
        let viewModel = CardConsentCellViewModel(
            image: image,
            text: "\(brand.capitalized) •••• \(card.last4 ?? "")",
            buttonAction: { [weak self] in
                self?.showAlertForDelete(consent, indexPath: indexPath)
            }
        )
        cell.setup(viewModel)
        return cell
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
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
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
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerReusableCell(CardConsentCell.self)
        collectionView.registerSectionHeader(CardPaymentSectionHeader.self)
    }
    
    private var paymentSessionHandler: PaymentUISessionHandler?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let consent = consents[indexPath.item]
        guard let viewController = context.viewController else {
            assert(false, "view controller not found")
            return
        }
        if consent.paymentMethod?.card?.numberType == "PAN" {
            let vc = AWXPaymentViewController(nibName: nil, bundle: nil)
            vc.delegate = AWXUIContext.shared().delegate
            vc.session = session
            vc.paymentConsent = consent
            viewController.navigationController?.pushViewController(vc, animated: true)
        } else {
            paymentSessionHandler = PaymentUISessionHandler(
                session: session,
                paymentConsent: consent,
                viewController: viewController
            )
            paymentSessionHandler?.startPayment()
        }
    }
    
    // actions
    func showAlertForDelete(_ consent: AWXPaymentConsent, indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("Would you like to delete this card?", comment: ""),
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
                        guard let index = self.consents.firstIndex(of: consent) else { return }
                        self.consents.remove(at: index)
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
            title: NSLocalizedString("Cancel", comment: "cancel delete consent"),
            style: .cancel
        )
        alert.addAction(cancelAction)
        context.viewController?.present(alert, animated: true)
    }
}
