//
//  SchemaPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

/// This section controlelr is for schema payment
class SchemaPaymentSectionController: NSObject, SectionController {
    
    struct Item {
        static let accordionKey = "schemaPaymentAccordionKey"
        static let bankName = AWXField.Name.bankName
        static let redirectReminder = "redirectReminder"
        static let checkoutButton = "checkoutButton"
    }
    
    private var session: AWXSession {
        methodProvider.session
    }
    private var paymentSessionHandler: PaymentSessionHandler?
    private var methodProvider: PaymentMethodProvider
    
    // data from method details API
    private var schema: AWXSchema?
    private var bankList: [AWXBank]?
    private var task: Task<Void, Never>?
    private var bankSelectionViewModel: BankSelectionCellViewModel?
    
    private var uiFieldViewModels = [InfoCollectorTextFieldViewModel]()
    private let name: String
    private let imageLoader: ImageLoader
    
    let layout: AWXUIContext.PaymentLayout
    private let methodType: AWXPaymentMethodType
    
    init(methodType: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         layout: AWXUIContext.PaymentLayout,
         imageLoader: ImageLoader) {
        assert(methodType.name != AWXCardKey && methodType.name != AWXApplePayKey && methodType.hasSchema)
        self.methodType = methodType
        self.name = methodType.name
        self.section = PaymentSectionType.schemaPayment(name)
        self.methodProvider = methodProvider
        self.layout = layout
        self.imageLoader = imageLoader
    }
    
    // MARK: - SectionController
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String] {
        var items = [String]()
        
        if layout == .accordion {
            items.append(Item.accordionKey)
        }
        
        if bankSelectionViewModel != nil {
            items.append(Item.bankName)
        }
        
        if let uiFields = schema?.uiFields {
            items.append(contentsOf: uiFields.map { $0.name })
        }
        
        items.append(Item.redirectReminder)
        items.append(Item.checkoutButton)
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let paymentGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: paymentGroup)
        section.interGroupSpacing = 24
        switch layout {
        case .tab:
            section.contentInsets = .init(horizontal: 16)
        case .accordion:
            section.contentInsets = .init(top: 16, leading: 40, bottom: 32, trailing: 40)
            
            // Layout for decoration - rounded corner
            context.register(RoundedCornerDecorationView.self, forDecorationViewOfKind: AccordionSectionController.backgroundElementKind)
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: AccordionSectionController.backgroundElementKind)
            sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(horizontal: 16)
            section.decorationItems = [sectionBackgroundDecoration]
        }
        return section
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        switch itemIdentifier {
        case Item.accordionKey:
            let cell = context.dequeueReusableCell(AccordionSelectedMethodCell.self, for: itemIdentifier, indexPath: indexPath)
            let viewModel = PaymentMethodCellViewModel(
                itemIdentifier: itemIdentifier,
                name: methodType.displayName,
                imageURL: methodType.resources.logoURL,
                isSelected: true,
                imageLoader: imageLoader,
                cardBrands: []
            )
            cell.setup(viewModel)
            return cell
        case Item.checkoutButton:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(CheckoutButtonCellViewModel(checkoutAction: checkout))
            return cell
        case Item.redirectReminder:
            return context.dequeueReusableCell(SchemaPaymentReminderCell.self, for: itemIdentifier, indexPath: indexPath)
        case Item.bankName:
            let cell = context.dequeueReusableCell(BankSelectionCell.self, for: itemIdentifier, indexPath: indexPath)
            assert(bankSelectionViewModel != nil)
            if let bankSelectionViewModel {
                cell.setup(bankSelectionViewModel)
            }
            return cell
        default:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: itemIdentifier, indexPath: indexPath)
            if let viewModel = uiFieldViewModels.first(where: { $0.fieldName == itemIdentifier}) {
                cell.setup(viewModel)
            } else {
                assert(false)
            }
            return cell
        }
    }
    
    func collectionView(didSelectItem item: String, at indexPath: IndexPath) {
        context.endEditing()
    }
    
    func updateItemsIfNecessary() {
        guard schema == nil && task == nil else {
            // don't send request again if we already have schema info
            return
        }
        task = Task {
            do {
                // block user from checkout when paymentmethod type is loading
                context.viewController?.startLoading()
                defer {
                    context.viewController?.stopLoading()
                }
                //  request method details from server
                let response = try await methodProvider.getPaymentMethodTypeDetails(name: name)
                //  check schema
                let schema = response.schemas.first { $0.transactionMode == session.transactionMode() }
                guard let schema, !schema.fields.isEmpty else {
                    throw NSLocalizedString("Invalid schema", bundle: .paymentSheet, comment: "").asError()
                }
                self.schema = schema
                
                // update bank selection
                var bankList: [AWXBank]?
                if schema.bankField != nil {
                    let banks = try await methodProvider.getBankList(name: name).items
                    guard !banks.isEmpty else {
                        throw NSLocalizedString("Invalid schema", bundle: .paymentSheet, comment: "").asError()
                    }
                    bankSelectionViewModel = BankSelectionCellViewModel(
                        bank: banks.count == 1 ? banks.first! : nil,
                        itemIdentifier: Item.bankName,
                        handleUserInteraction: { [weak self] in
                            self?.handleBankSelection()
                        },
                        cellReconfigureHandler: { [weak self] in
                            self?.context.reconfigure(items: [$0], invalidateLayout: $1)
                        }
                    )
                    bankList = banks
                }
                self.bankList = bankList
                
                uiFieldViewModels = schema.uiFields.reduce(into: [InfoCollectorTextFieldViewModel](), { partialResult, field in
                    //  create view model for UI fields
                    let viewModel = InfoCollectorCellViewModel(
                        itemIdentifier: field.name,
                        textFieldType: field.textFieldType,
                        title: field.displayName,
                        returnActionHandler: { [weak self] itemIdentifier, _ in
                            guard let self else { return false }
                            let success = self.context.activateNextRespondableCell(
                                section: self.section,
                                itemIdentifier: itemIdentifier
                            )
                            return success
                        },
                        cellReconfigureHandler: { [weak self] in
                            self?.context.reconfigure(items: [$0], invalidateLayout: $1)
                        }
                    )
                    if field.uiType == AWXField.UIType.phone {
                        let prefix = AWXField.phonePrefix(
                            countryCode: session.countryCode,
                            currencyCode: session.currency()
                        )
                        
                        if let prefix, !prefix.isEmpty {
                            // prefill with phone number in shipping address if it has the expected prefix
                            if let phoneNumber = self.session.billing?.phoneNumber {
                                if phoneNumber.hasPrefix(prefix) {
                                    viewModel.text = phoneNumber
                                } else {
                                    viewModel.text = prefix
                                }
                            }
                            viewModel.inputValidator = PrefixPhoneNumberValidator(prefix: prefix)
                        } else {
                            viewModel.text = self.session.billing?.phoneNumber
                        }
                    } else if field.uiType == AWXField.UIType.email {
                        viewModel.text = self.session.billing?.email
                    } else if field.uiType == AWXField.UIType.text {
                        if field.name == "shopper_name" {
                            viewModel.text = self.session.billing?.fullName
                        }
                    }
                    
                    //  update return key and handler
                    if let last = partialResult.last {
                        last.returnKeyType = .next
                    }
                    //  update partial result
                    partialResult.append(viewModel)
                })
                //  avoid recursion by passing false to updateItems:
                context.performUpdates(section, updateItems: false, animatingDifferences: true)
                task = nil
            } catch {
                schema = nil
                bankList = nil
                task = nil
                context.viewController?.showAlert(message: error.localizedDescription)
                debugLog("Failed to get schema for selected method. Error: \(error.localizedDescription)")
            }
        }
    }
    
    func sectionWillDisplay() {
        AnalyticsLogger.log(paymentMethodView: name)
        // check schema data before displaying to user
        updateItemsIfNecessary()
    }
}

private extension SchemaPaymentSectionController {
    func checkout() {
        context.endEditing()
        AnalyticsLogger.log(action: .tapPayButton, extraInfo: [.paymentMethod: name])
        guard let schema else {
            // check schema
            updateItemsIfNecessary()
            return
        }
        
        do {
            // validate bank selection
            try bankSelectionViewModel?.validate()
            
            // validate uiFields
            for viewModel in uiFieldViewModels {
                do {
                    try viewModel.validate()
                } catch {
                    context.scroll(to: viewModel.fieldName, position: .bottom, animated: true)
                    throw error
                }
            }
            
            let paymentMethod = AWXPaymentMethod()
            paymentMethod.type = name
            
            // update bank selection
            if let bankSelectionViewModel  {
                paymentMethod.appendAdditionalParams([bankSelectionViewModel.fieldName: bankSelectionViewModel.bank?.name ?? ""])
            }
            
            //  update from UI fields
            let inputContents = uiFieldViewModels.reduce(into: [String: String]()) { partialResult, viewModel in
                partialResult[viewModel.fieldName] = viewModel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            paymentMethod.appendAdditionalParams(inputContents)
            
            // update hidden fields
            paymentMethod.appendAdditionalParams(schema.parametersForHiddenFields(countryCode: session.countryCode))
            
            do {
                paymentSessionHandler = PaymentSessionHandler(
                    session: session,
                    viewController: context.viewController!,
                    paymentResultDelegate: AWXUIContext.shared.delegate,
                    methodType: methodProvider.method(named: name),
                    dismissAction: { completion in
                        AWXUIContext.shared.dismissAction?(completion)
                        // clear dismissAction block here so the user cancel detection
                        // in AWXPaymentViewController.deinit() can work as expected
                        AWXUIContext.shared.dismissAction = nil
                    }
                )
                try paymentSessionHandler?.confirmRedirectPayment(with: paymentMethod)
            } catch {
                context.viewController?.showAlert(message: error.localizedDescription)
            }
            
            debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")
        } catch {
            context.viewController?.showAlert(message: error.localizedDescription)
            for viewModel in uiFieldViewModels {
                viewModel.handleDidEndEditing(reconfigureStrategy: .onValidationChange)
            }
        }
    }
    
    func handleBankSelection() {
        context.endEditing()
        guard let bankList = bankList else { return }
        let formMapping = AWXFormMapping()
        formMapping.title = NSLocalizedString("Select your Bank", bundle: .paymentSheet, comment: "")
        formMapping.forms = bankList.map { bank in
            let form = AWXForm.init(key: bank.name, type: .listCell, title: bank.displayName, logo: bank.resources.logoURL)
            return form
        }
        // this pseudoMethod is only used to satisfy AWXPaymentFormViewController and will never be used
        let pseudoMethod = AWXPaymentMethod()
        let controller = AWXPaymentFormViewController()
        controller.delegate = self
        controller.viewModel = AWXPaymentFormViewModel(session: session, paymentMethod: pseudoMethod, formMapping: formMapping)
        controller.paymentMethod = pseudoMethod
        controller.formMapping = formMapping
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        context.viewController?.present(controller, animated: false)
    }
}

extension SchemaPaymentSectionController: AWXPaymentFormViewControllerDelegate {
    func paymentFormViewController(_ paymentFormViewController: AWXPaymentFormViewController, didSelectOption optionKey: String) {
        guard let bank = bankList?.first(where: { $0.name == optionKey }) else { return }
        bankSelectionViewModel?.bank = bank
        AnalyticsLogger.log(action: .selectBank, extraInfo: [.bankName: optionKey])
        paymentFormViewController.dismiss(animated: true)
    }
}
