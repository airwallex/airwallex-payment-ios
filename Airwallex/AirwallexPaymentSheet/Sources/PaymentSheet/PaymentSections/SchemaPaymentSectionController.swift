//
//  SchemaPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif
    
// MARK: - Item Identifiers
private extension String {
    static let accordionKey = "accordionKey"
    static let bankName = "bankName"
    static let redirectReminder = "redirectReminder"
    static let checkoutButton = "checkoutButton"
}
    
/// This section controlelr is for schema payment
class SchemaPaymentSectionController: NSObject, PaymentSectionController {
    typealias SectionItem = CompoundItem<PaymentSectionType, String>
    private var session: AWXSession {
        methodProvider.session
    }
    private var paymentSessionHandler: PaymentSessionHandlerProtocol?
    private var methodProvider: PaymentMethodProvider
    let paymentUIContext: PaymentSheetUIContext
    
    // data from method details API
    private var schema: AWXSchema?
    private var bankList: [AWXBank]?
    private var task: Task<Void, Never>?
    private var bankSelectionViewModel: BankSelectionCellViewModel?
    
    private var uiFieldViewModels = [InfoCollectorTextFieldViewModel]()
    private let name: String

    private let methodType: AWXPaymentMethodType

    init(methodType: AWXPaymentMethodType,
         methodProvider: PaymentMethodProvider,
         paymentUIContext: PaymentSheetUIContext) {
        assert(methodType.name != AWXCardKey && methodType.name != AWXApplePayKey && methodType.hasSchema)
        self.methodType = methodType
        self.name = methodType.name
        self.section = PaymentSectionType.schemaPayment(name)
        self.methodProvider = methodProvider
        self.paymentUIContext = paymentUIContext
    }
    
    // MARK: - SectionController
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String] {
        var items = [String]()
    
        if paymentUIContext.layout == .accordion {
            items.append(.accordionKey)
        }
    
        if bankSelectionViewModel != nil {
            items.append(.bankName)
        }
    
        if let uiFields = schema?.uiFields {
            items.append(contentsOf: uiFields.map { $0.name })
        }
    
        items.append(.redirectReminder)
        items.append(.checkoutButton)
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
        switch paymentUIContext.layout {
        case .tab:
            section.contentInsets = .init(horizontal: paymentUIContext.isEmbedded ? 0 : 16)
        case .accordion:
            let sectionHorizontal: CGFloat = paymentUIContext.isEmbedded ? 24 : 40
            section.contentInsets = .init(top: 16, leading: sectionHorizontal, bottom: 24, trailing: sectionHorizontal)

            // Layout for decoration - rounded corner
            context.register(RoundedCornerDecorationView.self, forDecorationViewOfKind: AccordionSectionController.backgroundElementKind)
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: AccordionSectionController.backgroundElementKind)
            sectionBackgroundDecoration.contentInsets = NSDirectionalEdgeInsets(
                horizontal: paymentUIContext.isEmbedded ? 0 : 16
            )
            section.decorationItems = [sectionBackgroundDecoration]
        }
        return section
    }
    
    func cell(for sectionItem: SectionItem, at indexPath: IndexPath) -> UICollectionViewCell {
        let item = sectionItem.item
    
        switch item {
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
        case .checkoutButton:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: sectionItem, indexPath: indexPath)
            let viewModel = CheckoutButtonCellViewModel(
                shouldShowPayAsCta: session.shouldShowPayAsCta,
                checkoutAction: checkout
            )
            cell.setup(viewModel)
            return cell
        case .redirectReminder:
            let cell = context.dequeueReusableCell(PaymentReminderCell.self, for: sectionItem, indexPath: indexPath)
            cell.setup(.schema)
            return cell
        case .bankName:
            let cell = context.dequeueReusableCell(BankSelectionCell.self, for: sectionItem, indexPath: indexPath)
            assert(bankSelectionViewModel != nil)
            if let bankSelectionViewModel {
                cell.setup(bankSelectionViewModel)
            }
            return cell
        default:
            // item is the UI field name
            let fieldName = item
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: sectionItem, indexPath: indexPath)
            if let viewModel = uiFieldViewModels.first(where: { $0.fieldName == fieldName }) {
                cell.setup(viewModel)
            } else {
                assert(false)
            }
            return cell
        }
    }
    
    func collectionView(didSelectItem sectionItem: SectionItem, at indexPath: IndexPath) {
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
                context.startLoading(for: section)
                defer {
                    context.stopLoading()
                }
                //  request method details from server
                let response = try await methodProvider.getPaymentMethodTypeDetails(name: name)
                //  check schema
                let schema = response.schemas.first { $0.transactionMode == session.transactionMode() }
                guard let schema, !schema.fields.isEmpty else {
                    throw NSLocalizedString("Invalid schema", bundle: .paymentSheet, comment: "schema section - invalid schema data").asError()
                }
                self.schema = schema
                
                // update bank selection
                if schema.bankField != nil {
                    let banks = try await methodProvider.getBankList(name: name).items
                    if banks.isEmpty {
                        bankList = nil
                        bankSelectionViewModel = nil
                    } else {
                        bankList = banks
                        bankSelectionViewModel = BankSelectionCellViewModel(
                            bank: banks.count == 1 ? banks.first! : nil,
                            itemIdentifier: .bankName,
                            handleUserInteraction: { [weak self] in
                                self?.handleBankSelection()
                            },
                            cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                                guard let self else { return }
                                self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
                            }
                        )
                    }
                } else {
                    self.bankList = bankList
                    self.bankSelectionViewModel = nil
                }
    
                uiFieldViewModels = schema.uiFields.reduce(into: [InfoCollectorTextFieldViewModel](), { partialResult, field in
                    //  create view model for UI fields
                    let viewModel = InfoCollectorCellViewModel(
                        itemIdentifier: field.name,
                        fieldName: field.name,
                        textFieldType: field.textFieldType,
                        title: field.displayName,
                        returnActionHandler: { [weak self] itemIdentifier, _ in
                            guard let self else { return false }
                            let success = self.context.activateNextRespondableCell(
                                section: self.section,
                                sectionItem: sectionItem(itemIdentifier)
                            )
                            return success
                        },
                        cellReconfigureHandler: { [weak self] itemIdentifier, invalidateLayout in
                            guard let self else { return }
                            self.context.reconfigure(items: [sectionItem(itemIdentifier)], invalidateLayout: invalidateLayout)
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
                    if let validator = SchemaFieldValidator(field: field) {
                        viewModel.inputValidator = validator
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
                UIViewController.topMost?.showAlert(message: error.localizedDescription)
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

        // Validation phase
        do {
            // validate bank selection
            try bankSelectionViewModel?.validate()
            // validate uiFields
            for viewModel in uiFieldViewModels {
                try viewModel.validate()
            }
        } catch {
            for viewModel in uiFieldViewModels {
                viewModel.handleDidEndEditing(reconfigureStrategy: .onValidationChange)
            }
            return
        }

        // Confirm payment phase
        let paymentMethod = buildPaymentMethod(schema: schema)
        confirmRedirectPayment(paymentMethod: paymentMethod)
    }

    func buildPaymentMethod(schema: AWXSchema) -> AWXPaymentMethod {
        let paymentMethod = AWXPaymentMethod()
        paymentMethod.type = name

        // update bank selection
        if let bankSelectionViewModel {
            paymentMethod.appendAdditionalParams([bankSelectionViewModel.fieldName: bankSelectionViewModel.bank?.name ?? ""])
        }

        // update from UI fields
        let inputContents = uiFieldViewModels.reduce(into: [String: String]()) { partialResult, viewModel in
            partialResult[viewModel.fieldName] = viewModel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        paymentMethod.appendAdditionalParams(inputContents)

        // update hidden fields
        paymentMethod.appendAdditionalParams(schema.parametersForHiddenFields(countryCode: session.countryCode))

        return paymentMethod
    }

    func confirmRedirectPayment(paymentMethod: AWXPaymentMethod) {
        paymentSessionHandler = paymentUIContext.paymentSessionHandlerFactory.createHandler(
            session: session,
            methodType: methodProvider.method(named: name),
            paymentUIContext: paymentUIContext
        )
        prepareForEmbeddedCheckout(paymentMethod: name, handler: paymentSessionHandler)
        Task { [weak self] in
            guard let self else { return }
            await paymentSessionHandler?.confirmRedirectPayment(with: paymentMethod)
            debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")
        }
    }

    func handleBankSelection() {
        context.endEditing()
        guard let bankList = bankList else { return }
        let formMapping = AWXFormMapping()
        formMapping.title = NSLocalizedString("Select your Bank", bundle: .paymentSheet, comment: "schema section - title of Bank Selection form")
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
        UIViewController.topMost?.present(controller, animated: false)
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
