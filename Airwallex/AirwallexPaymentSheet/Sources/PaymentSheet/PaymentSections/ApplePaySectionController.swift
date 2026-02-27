//
//  ApplePaySectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif
    
// MARK: - Item Identifiers
private extension String {
    static let accordionKey = "accordionKey"
    static let applePayReminder = "applePayReminder"
    static let applePayButton = "applePayButton"
}
    
class ApplePaySectionController: SectionController {
    typealias SectionItem = CompoundItem<PaymentSectionType, String>

    /// Layout type for Apple Pay section.
    enum LayoutType {
        /// Standalone Apple Pay button at top (prioritized)
        case prioritized
        /// Selected from tab list - reminder + button, no decoration
        case tab
        /// Selected in accordion - accordion key + reminder + button, with decoration
        case accordion
    }

    private let session: AWXSession
    private let methodType: AWXPaymentMethodType
    private var paymentSessionHandler: PaymentSessionHandler?
    private let methodProvider: PaymentMethodProvider
    private let paymentUIContext: PaymentSheetUIContext

    init(session: AWXSession,
         methodType: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         paymentUIContext: PaymentSheetUIContext) {
        assert(methodType.name == AWXApplePayKey)
        self.session = session
        self.methodType = methodType
        self.methodProvider = methodProvider
        self.paymentUIContext = paymentUIContext
    }

    let section = PaymentSectionType.applePay

    private var layoutType: LayoutType {
        if paymentUIContext.showsApplePayAsPrimaryButton {
            return .prioritized
        }
        switch paymentUIContext.layout {
        case .tab:
            return .tab
        case .accordion:
            return .accordion
        }
    }

    var items: [String] {
        switch layoutType {
        case .prioritized:
            return [.applePayButton]
        case .tab:
            return [.applePayReminder, .applePayButton]
        case .accordion:
            return [.accordionKey, .applePayReminder, .applePayButton]
        }
    }
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell {

        switch sectionItem.item {
        case .accordionKey:
            let cell = context.dequeueReusableCell(AccordionSelectedMethodCell.self, for: sectionItem, indexPath: indexPath)
            let viewModel = PaymentMethodCellViewModel(
                name: methodType.name,
                displayName: methodType.displayName,
                imageURL: methodType.resources.logoURL,
                isSelected: true,
                imageLoader: paymentUIContext.imageLoader,
                cardBrands: []
            )
            cell.setup(viewModel)
            return cell
        case .applePayReminder:
            let cell = context.dequeueReusableCell(PaymentReminderCell.self, for: sectionItem, indexPath: indexPath)
            cell.setup(.applePay)
            return cell
        case .applePayButton:
            let cell = context.dequeueReusableCell(ApplePayCell.self, for: sectionItem, indexPath: indexPath)
            let viewModel = ApplePayViewModel { [weak self] in
                guard let self else { return }
                checkout()
            }
            cell.setup(viewModel)
            return cell
        default:
            assert(false, "unexpected item: \(sectionItem)")
            return UICollectionViewCell()
        }
    }

    func checkout() {
        AnalyticsLogger.log(action: .tapPayButton, extraInfo: [.paymentMethod: methodType.name])

        paymentSessionHandler = PaymentSessionHandler(
            session: session,
            methodType: methodType,
            paymentUIContext: paymentUIContext
        )
        if paymentUIContext.isEmbedded {
            paymentUIContext.currentPaymentMethod = AWXApplePayKey
            if let element = paymentUIContext.paymentElement {
                element.delegate?.paymentElement?(element, didStartPaymentFor: AWXApplePayKey)
            }
            paymentSessionHandler?.showIndicator = false
            if paymentUIContext.showsPaymentProcessingIndicator {
                context.startLoading(for: section)
            }
        }
        paymentSessionHandler?.confirmApplePay(cancelPaymentOnDismiss: paymentUIContext.isEmbedded)
    }

    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
        context.endEditing()
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
        switch layoutType {
        case .prioritized:
            return layoutForPrioritized()
        case .tab:
            return layoutForTab()
        case .accordion:
            return layoutForAccordion()
        }
    }

    /// Layout for prioritized Apple Pay (button only, with separator footer if other methods exist)
    private func layoutForPrioritized() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(48)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let layoutSection = NSCollectionLayoutSection(group: group)
        var contentInsets = NSDirectionalEdgeInsets(horizontal: paymentUIContext.isEmbedded ? 0 : 16)
        if methodProvider.methods.contains(where: { $0.name != AWXApplePayKey }) {
            contentInsets.bottom = 16
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(22)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            layoutSection.boundarySupplementaryItems = [header]
        }
        layoutSection.contentInsets = contentInsets
        return layoutSection
    }

    /// Layout for Apple Pay selected from tab list (reminder + button, no decoration)
    private func layoutForTab() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let reminderItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let buttonSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(48))
        let buttonItem = NSCollectionLayoutItem(layoutSize: buttonSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let paymentGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [reminderItem, buttonItem]
        )
        paymentGroup.interItemSpacing = .fixed(24)
        let layoutSection = NSCollectionLayoutSection(group: paymentGroup)
        let sectionHorizontal: CGFloat = paymentUIContext.isEmbedded ? 0 : 16
        layoutSection.contentInsets = .init(horizontal: sectionHorizontal)
        return layoutSection
    }

    /// Layout for Apple Pay selected in accordion (header + reminder + button, with decoration)
    private func layoutForAccordion() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let accordionKeyItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let reminderItem = NSCollectionLayoutItem(layoutSize: itemSize)
        let buttonSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(48))
        let buttonItem = NSCollectionLayoutItem(layoutSize: buttonSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let paymentGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [accordionKeyItem, reminderItem, buttonItem]
        )
        paymentGroup.interItemSpacing = .fixed(24)
        let layoutSection = NSCollectionLayoutSection(group: paymentGroup)
        let sectionHorizontal: CGFloat = paymentUIContext.isEmbedded ? 24 : 40
        layoutSection.contentInsets = .init(top: 16, leading: sectionHorizontal, bottom: 24, trailing: sectionHorizontal)

        // Layout for decoration - rounded corner
        context.register(RoundedCornerDecorationView.self, forDecorationViewOfKind: AccordionSectionController.backgroundElementKind)
        let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: AccordionSectionController.backgroundElementKind)
        sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(
            horizontal: paymentUIContext.isEmbedded ? 0 : 16
        )
        layoutSection.decorationItems = [sectionBackgroundDecoration]
        return layoutSection
    }
    
    func sectionWillDisplay() {
        AnalyticsLogger.log(paymentMethodView: .applePay)
    }
}
