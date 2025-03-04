//
//  SchemaPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//
import AirwallexRisk

/// This section controlelr is for schema payment
class SchemaPaymentSectionController: NSObject, SectionController {
    
    struct Item {
        static let bankSelection = "bankSelection"
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
    private var bankSelectionViewModel: BankSelectionViewModel?
    
    private var uiFieldViewModels = [InfoCollectorTextFieldViewModel]()
    private let name: String
    
    init(name: String, methodProvider: PaymentMethodProvider) {
        self.name = name
        self.section = PaymentSectionType.schemaPayment(name)
        self.methodProvider = methodProvider
        super.init()
        self.updateItemsIfNecessary()
    }
    
    // MARK: - SectionController
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String] {
        var items = [String]()
        
        if let bankSelectionViewModel {
            items.append(Item.bankSelection)
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
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(horizontal: .spacing_16)
        section.interGroupSpacing = .spacing_24
        return section
    }
    
    func cell(for itemIdentifier: String, at indexPath: IndexPath) -> UICollectionViewCell {
        switch itemIdentifier {
        case Item.checkoutButton:
            let cell = context.dequeueReusableCell(CheckoutButtonCell.self, for: itemIdentifier, indexPath: indexPath)
            cell.setup(CheckoutButtonCellViewModel(checkoutAction: checkout))
            return cell
        case Item.redirectReminder:
            return context.dequeueReusableCell(SchemaPaymentReminderCell.self, for: itemIdentifier, indexPath: indexPath)
        case Item.bankSelection:
            let cell = context.dequeueReusableCell(BankSelectionCell.self, for: itemIdentifier, indexPath: indexPath)
            if let bankSelectionViewModel {
                cell.setup(bankSelectionViewModel)
            }
            return cell
        default:
            let cell = context.dequeueReusableCell(InfoCollectorCell.self, for: itemIdentifier, indexPath: indexPath)
            if let viewModel = uiFieldViewModels.first(where: { $0.fieldName == itemIdentifier}) {
                cell.setup(viewModel)
            }
            return cell
        }
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
                    throw NSLocalizedString("Invalid schema", bundle: .payment, comment: "").asError()
                }
                self.schema = schema
                
                // update bank selection
                var bankList: [AWXBank]?
                if let bankField = schema.bankField {
                    let banks = try await methodProvider.getBankList(name: name).items
                    guard !banks.isEmpty else {
                        throw NSLocalizedString("Invalid schema", bundle: .payment, comment: "").asError()
                    }
                    bankSelectionViewModel = BankSelectionViewModel(
                        bank: banks.count == 1 ? banks.first! : nil,
                        handleUserInteraction: { [weak self] in
                            self?.handleBankSelection()
                        }
                    )
                    bankList = banks
                }
                self.bankList = bankList
                
                uiFieldViewModels = schema.uiFields.reduce(into: [InfoCollectorTextFieldViewModel](), { partialResult, field in
                    //  create view model for UI fields
                    let viewModel = InfoCollectorTextFieldViewModel(
                        fieldName: field.name,
                        title: field.displayName,
                        textFieldType: field.textFieldType,
                        triggerLayoutUpdate: { [weak self] in
                            self?.context.invalidateLayout(for: [field.name])
                        }
                    )
                    if field.uiType == AWXField.UIType.phone {
                        if let prefix = AWXField.phonePrefix(countryCode: session.countryCode, currencyCode: session.currency()),
                           !prefix.isEmpty {
                            viewModel.text = prefix
                            viewModel.customInputValidator = { text in
                                guard let text, text.count > prefix.count else {
                                    throw NSLocalizedString("Invalid phone number", bundle: .payment, comment: "").asError()
                                }
                            }
                        }
                    }
                    
                    //  update return key and handler
                    if let last = partialResult.last {
                        last.returnKeyType = .next
                        last.returnActionHandler = { [weak self] _ in
                            guard let self else { return }
                            self.context.scroll(to: field.name, position: .bottom, animated: true)
                            if let cell = self.context.cellForItem(field.name) as? InfoCollectorCell {
                                let _ = cell.becomeFirstResponder()
                            }
                        }
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
}

private extension SchemaPaymentSectionController {
    func checkout() {
        AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button", additionalInfo: ["payment_method": name])
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
                    try viewModel.validateUserInput(viewModel.text)
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
            
            paymentSessionHandler = PaymentSessionHandler(
                session: session,
                viewController: context.viewController!,
                paymentResultDelegate: AWXUIContext.shared().delegate,
                methodType: methodProvider.method(named: name)
            )
            paymentSessionHandler?.startSchemaPayment(with: paymentMethod)
            
            debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")
        } catch {
            context.viewController?.showAlert(message: error.localizedDescription)
            bankSelectionViewModel?.handleDidEndEditing()
            for viewModel in uiFieldViewModels {
                viewModel.handleDidEndEditing()
            }
            context.reload(sections: [section])
        }
    }
    
    func handleBankSelection() {
        guard let bankList = bankList else { return }
        let formMapping = AWXFormMapping()
        formMapping.title = NSLocalizedString("Select your Bank", bundle: .payment, comment: "")
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
        AWXAnalyticsLogger.shared().logAction(withName: "select_bank", additionalInfo: [ "bankName": optionKey ])
        paymentFormViewController.dismiss(animated: true) {
            self.context.reconfigure(items: [ Item.bankSelection] )
        }
    }
}
