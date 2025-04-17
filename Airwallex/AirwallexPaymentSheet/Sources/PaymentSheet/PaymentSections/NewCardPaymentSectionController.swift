//
//  NewCardPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine
import AirwallexRisk
import Combine
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif

class NewCardPaymentSectionController: NSObject, SectionController {
    
    static let subType = "card"
    
    enum Item: String {
        case accordionKey = "newCardAccordionKey"
        case consentToggle
        case cardInfo
        case checkoutButton
        // display this item only when session is AWXOneOffSession && has customerId
        case saveCardToggle
        case unionPayWarning
        
        // billing fields
        case cardholderName
        case billingFieldEmail
        case billingFieldPhone
        case billingFieldAddress
        case billingFieldCountryCode
    }
    
    private var methodType: AWXPaymentMethodType
    
    private var paymentSessionHandler: PaymentSessionHandler?
    private var session: AWXSession {
        methodProvider.session
    }
    private let methodProvider: PaymentMethodProvider
    private let switchToConsentPaymentAction: () -> Void
    private var shouldSaveCard = false
    private var shouldReuseShippingAddress: Bool
    
    private lazy var viewModelForAccordionKey = PaymentMethodCellViewModel(
        itemIdentifier: Item.accordionKey.rawValue,
        name: methodType.displayName,
        imageURL: methodType.resources.logoURL,
        isSelected: true,
        imageLoader: imageLoader,
        cardBrands: []
    )
    
    private lazy var viewModelForConsentToggle = CardPaymentToggleCellViewModel(
        title: NSLocalizedString("Add new", bundle: .paymentSheet, comment: ""),
        actionTitle: NSLocalizedString("Keep using saved cards", bundle: .paymentSheet, comment: ""),
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
    
    private let layout: AWXUIContext.PaymentLayout
    private let imageLoader: ImageLoader
    
    init(cardPaymentMethod: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         layout: AWXUIContext.PaymentLayout,
         imageLoader: ImageLoader,
         switchToConsentPaymentAction: @escaping () -> Void) {
        assert(cardPaymentMethod.name == AWXCardKey, "invalid method")
        self.methodType = cardPaymentMethod
        self.methodProvider = methodProvider
        self.switchToConsentPaymentAction = switchToConsentPaymentAction
        self.shouldReuseShippingAddress = methodProvider.session.billing?.address?.isComplete ?? false
        if let oneOffSession = methodProvider.session as? AWXOneOffSession {
            self.shouldSaveCard = oneOffSession.autoSaveCardForFuturePayments
        }
        self.layout = layout
        self.imageLoader = imageLoader
        super.init()
        createViewModelForRequiredFields()
    }
    
    // MARK: - SectionController
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section = PaymentSectionType.cardPaymentNew
    
    var items: [String] {
        var items = [String]()
        if layout == .accordion {
            items.append(Item.accordionKey.rawValue)
        }
        
        if !methodProvider.consents.isEmpty {
            items.append(Item.consentToggle.rawValue)
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
            items.append(Item.saveCardToggle.rawValue)
            if shouldSaveCard && viewModelForCardInfo.cardNumberConfigurer.currentBrand == .unionPay {
                items.append(Item.unionPayWarning.rawValue)
            }
        }
        
        items.append(Item.checkoutButton.rawValue)
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = Item(rawValue: itemIdentifier) else { fatalError("Invalid item") }
        switch item {
        case .accordionKey:
            let cell = context.dequeueReusableCell(AccordionSelectedMethodCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(viewModelForAccordionKey)
            return cell
        case .consentToggle:
            let cell = context.dequeueReusableCell(CardPaymentToggleCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(viewModelForConsentToggle)
            return cell
        case .cardInfo:
            let cell = context.dequeueReusableCell(CardInfoCollectorCell.self, for: item.rawValue, indexPath: indexPath)
            cell.setup(viewModelForCardInfo)
            return cell
        case .checkoutButton:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: item.rawValue, indexPath: indexPath)
            cell.setup(CheckoutButtonCellViewModel(checkoutAction: checkout))
            return cell
        case .saveCardToggle:
            let cell = context.dequeueReusableCell(CheckBoxCell.self, for: item.rawValue, indexPath: indexPath)
            let viewModel = CheckBoxCellViewModel(
                isSelected: shouldSaveCard,
                title: nil,
                boxInfo: NSLocalizedString("Save my card for future payments", comment: "checkbox in checkout view"),
                selectionDidChanged: toggleCardSaving
            )
            cell.setup(viewModel)
            return cell
        case .billingFieldAddress:
            let cell = context.dequeueReusableCell(BillingInfoCell.self, for: item.rawValue, indexPath: indexPath)
            if let viewModelForBillingAddress {
                cell.setup(viewModelForBillingAddress)
            } else {
                assert(false)
            }
            return cell
        case .unionPayWarning:
            let cell = context.dequeueReusableCell(WarningViewCell.self, for: item.rawValue, indexPath: indexPath)
            let message = NSLocalizedString(
                "For UnionPay, only credit cards can be saved. Click “Pay” to proceed with a one time payment or use another card if you would like to save it for future use.",
                bundle: .paymentSheet,
                comment: ""
            )
            cell.setup(message)
            return cell
        case .cardholderName:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: item.rawValue, indexPath: indexPath)
            if let viewModelForCardholderName {
                cell.setup(viewModelForCardholderName)
            } else {
                assert(false)
            }
            return cell
        case .billingFieldEmail:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: item.rawValue, indexPath: indexPath)
            if let viewModelForEmail {
                cell.setup(viewModelForEmail)
            } else {
                assert(false)
            }
            return cell
        case .billingFieldPhone:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: item.rawValue, indexPath: indexPath)
            if let viewModelForPhoneNumber {
                cell.setup(viewModelForPhoneNumber)
            } else {
                assert(false)
            }
            return cell
        case .billingFieldCountryCode:
            let cell = context.dequeueReusableCell(CountrySelectionCell.self, for: item.rawValue, indexPath: indexPath)
            if let viewModelForCountryCode {
                cell.setup(viewModelForCountryCode)
            } else {
                assert(false)
            }
            return cell
        }
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
        switch layout {
        case .tab:
            section.contentInsets = .init(horizontal: 16)
        case .accordion:
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 40, bottom: 32, trailing: 40)
            
            // Layout for decoration - rounded corner
            let elementKind = AccordionSectionController.backgroundElementKind
            context.register(
                RoundedCornerDecorationView.self,
                forDecorationViewOfKind: elementKind
            )
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
            sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
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
        guard let session = session as? AWXOneOffSession,
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
        
        do {
            // validate card info
            let forCardValidation: [ViewModelValidatable?] = [
                viewModelForCardInfo,
                viewModelForCardholderName
            ]
            for viewModel in forCardValidation {
                try viewModel?.validate()
            }
            
            let card = viewModelForCardInfo.cardFromCollectedInfo()
            if let name = viewModelForCardholderName?.text?.trimmed {
                card.name = name
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
            
            // create billing info from required fields and session.billing
            let billingInfo = createBillingInfo()
            
            RiskLogger.log(.clickPaymentButton, screen: .createCard)
            debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")
            
            do {
                paymentSessionHandler = PaymentSessionHandler(
                    session: session,
                    viewController: context.viewController!,
                    paymentResultDelegate: AWXUIContext.shared().delegate,
                    methodType: methodType
                )
                try paymentSessionHandler?.confirmCardPayment(
                    with: card,
                    billing: billingInfo,
                    saveCard: shouldSaveCard
                )
            } catch {
                context.viewController?.showAlert(message: error.localizedDescription)
            }
        } catch {
            viewModelForCardInfo.updateValidStatusForCheckout()
            viewModelForBillingAddress?.updateValidStatusForCheckout()
            let otherViewModels: [InfoCollectorTextFieldViewModel?] = [
                viewModelForCardholderName,
                viewModelForEmail,
                viewModelForPhoneNumber,
                viewModelForCountryCode
            ]
            for viewModel in otherViewModels {
                viewModel?.handleDidEndEditing(reconfigureIfNeeded: true)
            }
            let message = error.localizedDescription
            context.viewController?.showAlert(message: message)
            
            AnalyticsLogger.log(
                action: .cardPaymentValidation,
                extraInfo: [
                    .message: message,
                    .subtype: Self.subType
                ]
            )
            debugLog("Payment failed. Intent ID: \(session.paymentIntentId() ?? ""). Reason: \(message)")
        }
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
        context.viewController?.present(nav, animated: true)
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
        context.reconfigure(items: [ viewModel.itemIdentifier ], invalidateLayout: true) { cell in
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
            itemIdentifier: Item.billingFieldAddress.rawValue,
            shippingAddress: session.billing?.address,
            reusingShippingInfo: reuseShippingAddress,
            countrySelectionHandler: { [weak self] in
                self?.triggerCountrySelection()
            },
            toggleReuseSelection: { [weak self] in
                guard let self else { return }
                self.toggleReuseShippingAddress()
            },
            cellReconfigureHandler: { [weak self] in
                self?.context.reconfigure(items: [$0], invalidateLayout: $1)
            }
        )
    }
    
    func createViewModelForRequiredFields() {
        viewModelForCardInfo = CardInfoCollectorCellViewModel(
            itemIdentifier: Item.cardInfo.rawValue,
            cardSchemes: methodType.cardSchemes,
            returnActionHandler: { [weak self] _, identifier in
                guard let self else { return false }
                return self.context.activateNextRespondableCell(
                    section: self.section,
                    itemIdentifier: identifier
                )
            },
            reconfigureHandler: { [weak self] in
                self?.context.reconfigure(items: [$0], invalidateLayout: $1)
            },
            cardNumberDidEndEditing: { [weak self] in
                guard let self else { return }
                self.context.performUpdates(self.section)
            }
        )
        
        let returnActionHandler: (UIResponder, String) -> Bool = { [weak self] responder, itemIdentifier in
            guard let self else { return false }
            return self.context.activateNextRespondableCell(
                section: self.section,
                itemIdentifier: itemIdentifier
            )
        }
        
        if session.requiredBillingContactFields.contains(.name) {
            let firstName = session.billing?.firstName ?? ""
            let lastName = session.billing?.lastName ?? ""
            let text = (firstName + " " + lastName).trimmed
            viewModelForCardholderName = InfoCollectorCellViewModel(
                itemIdentifier: Item.cardholderName.rawValue,
                textFieldType: .nameOnCard,
                title: NSLocalizedString("Name on card", bundle: .paymentSheet, comment: "billing field"),
                text: text,
                returnKeyType: .next,
                returnActionHandler: returnActionHandler,
                editingEventObserver: BeginEditingEventObserver {
                    RiskLogger.log(.inputCardHolderName, screen: .createCard)
                },
                cellReconfigureHandler: { [weak self] in
                    self?.context.reconfigure(items: [$0], invalidateLayout: $1)
                }
            )
        }
        if session.requiredBillingContactFields.contains(.email) {
            viewModelForEmail = InfoCollectorCellViewModel(
                itemIdentifier: Item.billingFieldEmail.rawValue,
                textFieldType: .email,
                title: NSLocalizedString("Email", bundle: .paymentSheet, comment: "billing field"),
                text: session.billing?.email,
                returnKeyType: .next,
                returnActionHandler: returnActionHandler,
                cellReconfigureHandler: { [weak self] in
                    self?.context.reconfigure(items: [$0], invalidateLayout: $1)
                }
            )
        }
        if session.requiredBillingContactFields.contains(.phone) {
            viewModelForPhoneNumber = InfoCollectorCellViewModel(
                itemIdentifier: Item.billingFieldPhone.rawValue,
                textFieldType: .phoneNumber,
                title: NSLocalizedString("Phone number", bundle: .paymentSheet, comment: "billing field"),
                text: session.billing?.phoneNumber,
                returnKeyType: .next,
                returnActionHandler: returnActionHandler,
                cellReconfigureHandler: { [weak self] in
                    self?.context.reconfigure(items: [$0], invalidateLayout: $1)
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
                itemIdentifier: Item.billingFieldCountryCode.rawValue,
                title: NSLocalizedString("Billing country or region", bundle: .paymentSheet, comment: "billing info"),
                country: country,
                handleUserInteraction: { [weak self] in
                    self?.triggerCountrySelection()
                },
                cellReconfigureHandler: { [weak self] in
                    self?.context.reconfigure(items: [$0], invalidateLayout: $1)
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
            context.reconfigure(items: [ viewModelForBillingAddress.itemIdentifier ], invalidateLayout: true)
        } else if let viewModelForCountryCode {
            viewModelForCountryCode.country = country
            context.reconfigure(items: [ viewModelForCountryCode.itemIdentifier ], invalidateLayout: true)
        }
    }
}

