//
//  NewCardPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import AirwallexRisk
import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif
    
// MARK: - Item Identifiers
private extension String {
    static let accordionKey = "accordionKey"
    static let consentToggle = "consentToggle"
    static let cardInfo = "cardInfo"
    static let checkoutButton = "checkoutButton"
    /// display this item only when session is AWXOneOffSession && has customerId
    static let saveCardToggle = "saveCardToggle"
    static let unionPayWarning = "unionPayWarning"
    // billing fields
    static let cardholderName = "cardholderName"
    static let billingFieldEmail = "billingFieldEmail"
    static let billingFieldPhone = "billingFieldPhone"
    static let billingFieldAddress = "billingFieldAddress"
    static let billingFieldCountryCode = "billingFieldCountryCode"
}
    
class NewCardPaymentSectionController: NSObject, PaymentSectionController {
    typealias SectionItem = CompoundItem<PaymentSectionType, String>
    static let subType = "card"
    
    private var methodType: AWXPaymentMethodType

    private var paymentSessionHandler: PaymentSessionHandlerProtocol?
    private var session: AWXSession {
        methodProvider.session
    }
    private let methodProvider: PaymentMethodProvider
    let paymentUIContext: PaymentSheetUIContext
    private let switchToConsentPaymentAction: () -> Void
    private var shouldSaveCard = false
    private var shouldReuseShippingAddress: Bool
    
    private lazy var viewModelForAccordionKey = PaymentMethodCellViewModel(
        name: methodType.name,
        displayName: methodType.displayName,
        imageURL: methodType.resources.logoURL,
        isSelected: true,
        imageLoader: paymentUIContext.imageLoader,
        cardBrands: []
    )
    
    private lazy var viewModelForConsentToggle = CardPaymentToggleCellViewModel(
        title: NSLocalizedString("Add new", bundle: .paymentSheet, comment: "add card section - section title"),
        actionTitle: NSLocalizedString("Keep using saved cards", bundle: .paymentSheet, comment: "add card section - button to switch to consent list"),
        buttonAction: { [weak self] in
            guard let self else { return }
            self.switchToConsentPaymentAction()
            
            AnalyticsLogger.log(
                action: .selectPayment,
                extraInfo: [
                    .paymentMethod: AWXCardKey,
                    .subtype: CardPaymentConsentSectionController.subType
                ]
            )
        }
    )
    private var viewModelForCardInfo: CardInfoCollectorCellViewModel!
    private(set) var viewModelForCardholderName: InfoCollectorCellViewModel<String>?
    private(set) var viewModelForEmail: InfoCollectorCellViewModel<String>?
    private(set) var viewModelForPhoneNumber: InfoCollectorCellViewModel<String>?
    private(set) var viewModelForCountryCode: CountrySelectionCellViewModel?
    private(set) var viewModelForBillingAddress: BillingInfoCellViewModel?

    init(cardPaymentMethod: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         paymentUIContext: PaymentSheetUIContext,
         switchToConsentPaymentAction: @escaping () -> Void) {
        assert(cardPaymentMethod.name == AWXCardKey, "invalid method")
        self.methodType = cardPaymentMethod
        self.methodProvider = methodProvider
        self.paymentUIContext = paymentUIContext
        self.switchToConsentPaymentAction = switchToConsentPaymentAction
        self.shouldReuseShippingAddress = methodProvider.session.billing?.address?.isComplete ?? false
        super.init()
        createViewModelForRequiredFields()
        if let session = session as? Session {
            self.shouldSaveCard = supportCardSaving && session.autoSaveCardForFuturePayments
        } else if let oneOffSession = methodProvider.session as? AWXOneOffSession {
            self.shouldSaveCard = supportCardSaving && oneOffSession.autoSaveCardForFuturePayments
        }
    }
    
    // MARK: - SectionController
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.cardPaymentNew
    
    var items: [String] {
        var items = [String]()
        if paymentUIContext.layout == .accordion {
            items.append(.accordionKey)
        }
    
        if !methodProvider.consents.isEmpty {
            items.append(.consentToggle)
        }
    
        let viewModels: [(any CellViewModelIdentifiable)?] = [
            viewModelForCardInfo,
            viewModelForCardholderName,
            viewModelForEmail,
            viewModelForPhoneNumber,
            viewModelForBillingAddress,
            viewModelForCountryCode
        ]
        for viewModel in viewModels {
            if let identifier = viewModel?.itemIdentifier as? String {
                items.append(identifier)
            }
        }
    
        if supportCardSaving {
            items.append(.saveCardToggle)
            if shouldSaveCard && viewModelForCardInfo.cardNumberConfigurer.currentBrand == .unionPay {
                items.append(.unionPayWarning)
            }
        }
    
        items.append(.checkoutButton)
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell {
        let item = sectionItem.item
    
        switch item {
        case .accordionKey:
            let cell = context.dequeueReusableCell(AccordionSelectedMethodCell.self, for: sectionItem, indexPath: indexPath)
            cell.setup(viewModelForAccordionKey)
            return cell
        case .consentToggle:
            let cell = context.dequeueReusableCell(CardPaymentToggleCell.self, for: sectionItem, indexPath: indexPath)
            cell.setup(viewModelForConsentToggle)
            return cell
        case .cardInfo:
            let cell = context.dequeueReusableCell(CardInfoCollectorCell.self, for: sectionItem, indexPath: indexPath)
            cell.setup(viewModelForCardInfo)
            return cell
        case .checkoutButton:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: sectionItem, indexPath: indexPath)
            let viewModel = CheckoutButtonCellViewModel(
                shouldShowPayAsCta: session.shouldShowPayAsCta,
                checkoutAction: checkout
            )
            cell.setup(viewModel)
            return cell
        case .saveCardToggle:
            let cell = context.dequeueReusableCell(CheckBoxCell.self, for: sectionItem, indexPath: indexPath)
            let viewModel = CheckBoxCellViewModel(
                isSelected: shouldSaveCard,
                title: nil,
                boxInfo: NSLocalizedString("Save my card for future payments", bundle: .paymentSheet, comment: "add card section - toggle for card saving"),
                selectionDidChanged: toggleCardSaving
            )
            cell.setup(viewModel)
            return cell
        case .billingFieldAddress:
            let cell = context.dequeueReusableCell(BillingInfoCell.self, for: sectionItem, indexPath: indexPath)
            if let viewModelForBillingAddress {
                cell.setup(viewModelForBillingAddress)
            } else {
                assert(false)
            }
            return cell
        case .unionPayWarning:
            let cell = context.dequeueReusableCell(WarningViewCell.self, for: sectionItem, indexPath: indexPath)
            let message = NSLocalizedString(
                "For UnionPay, only credit cards can be saved. Click “Pay” to proceed with a one time payment or use another card if you would like to save it for future use.",
                bundle: .paymentSheet,
                comment: "add card section - UnionPay warning message"
            )
            cell.setup(message)
            return cell
        case .cardholderName:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: sectionItem, indexPath: indexPath)
            if let viewModelForCardholderName {
                cell.setup(viewModelForCardholderName)
            } else {
                assert(false)
            }
            return cell
        case .billingFieldEmail:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: sectionItem, indexPath: indexPath)
            if let viewModelForEmail {
                cell.setup(viewModelForEmail)
            } else {
                assert(false)
            }
            return cell
        case .billingFieldPhone:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: sectionItem, indexPath: indexPath)
            if let viewModelForPhoneNumber {
                cell.setup(viewModelForPhoneNumber)
            } else {
                assert(false)
            }
            return cell
        case .billingFieldCountryCode:
            let cell = context.dequeueReusableCell(CountrySelectionCell.self, for: sectionItem, indexPath: indexPath)
            if let viewModelForCountryCode {
                cell.setup(viewModelForCountryCode)
            } else {
                assert(false)
            }
            return cell
        default:
            assert(false, "unexpected item: \(item)")
            return UICollectionViewCell()
        }
    }
    
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
        context.endEditing()
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        switch paymentUIContext.layout {
        case .tab:
            section.contentInsets = .init(horizontal: paymentUIContext.isEmbedded ? 0 : 16)
        case .accordion:
            let sectionHorizontal: CGFloat = paymentUIContext.isEmbedded ? 24 : 40
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: sectionHorizontal, bottom: 24, trailing: sectionHorizontal)

            // Layout for decoration - rounded corner
            let elementKind = AccordionSectionController.backgroundElementKind
            context.register(
                RoundedCornerDecorationView.self,
                forDecorationViewOfKind: elementKind
            )
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
            sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(
                horizontal: paymentUIContext.isEmbedded ? 0 : 16
            )
            section.decorationItems = [sectionBackgroundDecoration]
        }
        return section
    }
    
    func sectionWillDisplay() {
        RiskLogger.log(.showCreateCard, screen: .createCard)
        
        AnalyticsLogger.log(
            paymentMethodView: .card,
            extraInfo: [
                .subtype: Self.subType,
                .supportedSchemes: methodType.cardSchemes.compactMap { $0.name }
            ]
        )
    }
}
    
private extension NewCardPaymentSectionController {
    
    var supportCardSaving: Bool {
        guard session.transactionMode() == AWXPaymentTransactionModeOneOff,
           let customerId = session.customerId(),
           !customerId.isEmpty else {
            return false
        }
        return true
    }
    
    func checkout() {
        context.endEditing()
        AnalyticsLogger.log(
            action: .tapPayButton,
            extraInfo: [
                .paymentMethod: AWXCardKey,
                .subtype: Self.subType
            ]
        )

        // Validation phase
        do {
            try validateForCheckout()
        } catch {
            handleValidationFailure(error)
            return
        }

        // Confirm payment phase
        RiskLogger.log(.clickPaymentButton, screen: .createCard)
        debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")

        let card = viewModelForCardInfo.cardFromCollectedInfo()
        if let name = viewModelForCardholderName?.text?.trimmed {
            card.name = name
        }
        let billingInfo = createBillingInfo()
        confirmCardPayment(card: card, billing: billingInfo)
    }

    func validateForCheckout() throws {
        // validate card info
        let forCardValidation: [ViewModelValidatable?] = [
            viewModelForCardInfo,
            viewModelForCardholderName
        ]
        for viewModel in forCardValidation {
            try viewModel?.validate()
        }

        // validate billing info
        let forBillingValidation: [ViewModelValidatable?] = [
            viewModelForEmail,
            viewModelForPhoneNumber,
            viewModelForBillingAddress,
            viewModelForCountryCode
        ]
        for viewModel in forBillingValidation {
            try viewModel?.validate()
        }
    }

    func handleValidationFailure(_ error: Error) {
        viewModelForCardInfo.updateValidStatusForCheckout()
        viewModelForBillingAddress?.updateValidStatusForCheckout()
        let otherViewModels: [InfoCollectorTextFieldViewModel?] = [
            viewModelForCardholderName,
            viewModelForEmail,
            viewModelForPhoneNumber,
            viewModelForCountryCode
        ]
        for viewModel in otherViewModels {
            viewModel?.handleDidEndEditing(reconfigureStrategy: .onValidationChange)
        }

        scrollToFirstInvalidField()

        let message = error.localizedDescription

        AnalyticsLogger.log(
            action: .cardPaymentValidation,
            extraInfo: [
                .message: message,
                .subtype: Self.subType
            ]
        )
        debugLog("Payment failed. Intent ID: \(session.paymentIntentId() ?? ""). Reason: \(message)")
    }

    func scrollToFirstInvalidField() {
        // Check view models in the same order as validateForCheckout
        let validatableItems: [(viewModel: (any ViewModelValidatable)?, itemIdentifier: String)] = [
            (viewModelForCardInfo, .cardInfo),
            (viewModelForCardholderName, .cardholderName),
            (viewModelForEmail, .billingFieldEmail),
            (viewModelForPhoneNumber, .billingFieldPhone),
            (viewModelForBillingAddress, .billingFieldAddress),
            (viewModelForCountryCode, .billingFieldCountryCode)
        ]
        for entry in validatableItems {
            guard let viewModel = entry.viewModel else { continue }
            do {
                try viewModel.validate()
            } catch {
                let item = sectionItem(entry.itemIdentifier)
                if paymentUIContext.isEmbedded {
                    if let view = context.cellForItem(item) {
                        paymentUIContext.paymentElement?.notifyValidationFailed(
                            for: methodType.name,
                            invalidInputView: view
                        )
                    }
                } else {
                    context.ensureVisible(for: item)
                }
            }
        }
    }

    func confirmCardPayment(card: AWXCard, billing: AWXPlaceDetails) {
        paymentSessionHandler = paymentUIContext.paymentSessionHandlerFactory.createHandler(
            session: session,
            methodType: methodType,
            paymentUIContext: paymentUIContext
        )
        prepareForEmbeddedCheckout(paymentMethod: AWXCardKey, handler: paymentSessionHandler)
        paymentSessionHandler?.confirmCardPayment(
            with: card,
            billing: billing,
            saveCard: shouldSaveCard
        )
    }
    
    func createBillingInfo() -> AWXPlaceDetails {
        let billingInfo = AWXPlaceDetails()
        // update name
        if let viewModelForCardholderName {
            let name = viewModelForCardholderName.text?.trimmed ?? ""
            let components = name.components(separatedBy: " ")
            billingInfo.firstName = components.first ?? ""
            if components.count > 1 {
                billingInfo.lastName = String(name.dropFirst(billingInfo.firstName.count)).trimmed
            }
        }
        // update email
        if let viewModelForEmail {
            billingInfo.email = viewModelForEmail.text?.trimmed
        }
        // update phone number
        if let viewModelForPhoneNumber {
            billingInfo.phoneNumber = viewModelForPhoneNumber.text?.trimmed
        }
        // update address
        if let address = viewModelForBillingAddress?.billingAddressFromCollectedInfo() {
            billingInfo.address = address
        } else if let countryCode = viewModelForCountryCode?.country?.countryCode {
            let address = AWXAddress()
            address.countryCode = countryCode
            billingInfo.address = address
        }
        return billingInfo
    }
    
    func triggerCountrySelection() {
        context.endEditing()
        let controller = AWXCountryListViewController(nibName: nil, bundle: nil)
        controller.delegate = self
        controller.country = viewModelForBillingAddress?.selectedCountry ?? viewModelForCountryCode?.country
        let nav = UINavigationController(rootViewController: controller)
        UIViewController.topMost?.present(nav, animated: true)
    }
    
    func toggleReuseShippingAddress() {
        shouldReuseShippingAddress.toggle()
        AnalyticsLogger.log(
            action: .toggleBillingAddress,
            extraInfo: [
                .value: shouldReuseShippingAddress,
                .subtype: Self.subType
            ]
        )
        let viewModel = createBillingAddressViewModel(reuseShippingAddress: shouldReuseShippingAddress)
        viewModelForBillingAddress = viewModel
        context.reconfigure(items: [sectionItem(viewModel.itemIdentifier)], invalidateLayout: true) { cell in
            guard let cell = cell as? BillingInfoCell else { return }
            cell.setup(viewModel)
        }
    }
    
    func toggleCardSaving(_ shouldSaveCard: Bool) {
        AnalyticsLogger.log(
            action: .saveCard,
            extraInfo: [
                .value: shouldSaveCard,
                .subtype: Self.subType
            ]
        )
        self.shouldSaveCard = shouldSaveCard
        if viewModelForCardInfo.cardNumberConfigurer.currentBrand == .unionPay {
            // show warning view for union pay card
            context.performUpdates(section)
        }
    }
    
    func createBillingAddressViewModel(reuseShippingAddress: Bool) -> BillingInfoCellViewModel {
        BillingInfoCellViewModel(
            itemIdentifier: .billingFieldAddress,
            prefilledAddress: session.billing?.address,
            reusePrefilledAddress: reuseShippingAddress,
            countrySelectionHandler: { [weak self] in
                self?.triggerCountrySelection()
            },
            toggleReuseSelection: { [weak self] in
                guard let self else { return }
                self.toggleReuseShippingAddress()
            },
            cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                guard let self else { return }
                self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
            }
        )
    }
    
    func createViewModelForRequiredFields() {
        viewModelForCardInfo = CardInfoCollectorCellViewModel(
            itemIdentifier: .cardInfo,
            cardSchemes: methodType.cardSchemes,
            returnActionHandler: { [weak self] identifier, _ in
                guard let self else { return false }
                return self.context.activateNextRespondableCell(
                    section: self.section,
                    sectionItem: self.sectionItem(identifier)
                )
            },
            reconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                guard let self else { return }
                self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
            },
            cardNumberDidEndEditing: { [weak self] in
                guard let self else { return }
                // perform updates to hide or show unionpay warning view if necessary
                self.context.performUpdates(self.section)
            }
        )
    
        let returnActionHandler: (String, UIResponder) -> Bool = { [weak self] itemIdentifier, _ in
            guard let self else { return false }
            return self.context.activateNextRespondableCell(
                section: self.section,
                sectionItem: self.sectionItem(itemIdentifier)
            )
        }
    
        if session.requiredBillingContactFields.contains(.name) {
            let firstName = session.billing?.firstName ?? ""
            let lastName = session.billing?.lastName ?? ""
            let text = (firstName + " " + lastName).trimmed
            viewModelForCardholderName = InfoCollectorCellViewModel(
                itemIdentifier: .cardholderName,
                textFieldType: .nameOnCard,
                title: NSLocalizedString("Name on card", bundle: .paymentSheet, comment: "add card section - billing field"),
                text: text,
                returnKeyType: .next,
                returnActionHandler: returnActionHandler,
                editingEventObserver: BeginEditingEventObserver {
                    RiskLogger.log(.inputCardHolderName, screen: .createCard)
                },
                cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                    guard let self else { return }
                    self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
                }
            )
        }
        if session.requiredBillingContactFields.contains(.email) {
            viewModelForEmail = InfoCollectorCellViewModel(
                itemIdentifier: .billingFieldEmail,
                textFieldType: .email,
                title: NSLocalizedString("Email", bundle: .paymentSheet, comment: "add card section - billing field"),
                text: session.billing?.email,
                returnKeyType: .next,
                returnActionHandler: returnActionHandler,
                cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                    guard let self else { return }
                    self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
                }
            )
        }
        if session.requiredBillingContactFields.contains(.phone) {
            viewModelForPhoneNumber = InfoCollectorCellViewModel(
                itemIdentifier: .billingFieldPhone,
                textFieldType: .phoneNumber,
                title: NSLocalizedString("Phone number", bundle: .paymentSheet, comment: "add card section - billing field"),
                text: session.billing?.phoneNumber,
                returnKeyType: .next,
                returnActionHandler: returnActionHandler,
                cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                    guard let self else { return }
                    self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
                }
            )
        }
    
        if session.requiredBillingContactFields.contains(.address) {
            viewModelForBillingAddress = createBillingAddressViewModel(reuseShippingAddress: shouldReuseShippingAddress)
        } else if session.requiredBillingContactFields.contains(.countryCode) {
            var country: AWXCountry?
            if let countryCode = session.billing?.address?.countryCode {
                country = AWXCountry(code: countryCode)
            }
            viewModelForCountryCode = CountrySelectionCellViewModel(
                country: country,
                itemIdentifier: .billingFieldCountryCode,
                title: NSLocalizedString("Billing country or region", bundle: .paymentSheet, comment: "add card section - billing info"),
                handleUserInteraction: { [weak self] in
                    self?.triggerCountrySelection()
                },
                cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                    guard let self else { return }
                    self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
                }
            )
        }
    }
}
    
extension NewCardPaymentSectionController: AWXCountryListViewControllerDelegate {
    func countryListViewController(_ controller: AWXCountryListViewController, didSelect country: AWXCountry) {
        controller.dismiss(animated: true)
        assert(viewModelForBillingAddress != nil || viewModelForCountryCode != nil, "one of the viewmodel should exist")
        if let viewModelForBillingAddress {
            viewModelForBillingAddress.selectedCountry = country
        } else if let viewModelForCountryCode {
            viewModelForCountryCode.country = country
        }
    }
}
    
