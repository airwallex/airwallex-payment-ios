//
//  SchemaPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//
import AirwallexRisk

class SchemaPaymentSectionController: NSObject, SectionController {
    
    struct Item {
        static let bankSelection: String = "bankSelection"
        static let redirectRemider: String = "redirectRemider"
        static let checkoutButton: String = "checkoutButton"
    }
    
    private var session: AWXSession {
        methodProvider.session
    }
    private var methodType: AWXPaymentMethodType {
        guard case let PaymentSectionType.schemaPayment(name) = section,
              let methodType = methodProvider.method(named: name) else {
            fatalError("method type not found")
        }
        return methodType
    }
    private var paymentSessionHandler: PaymentUISessionHandler?
    private var methodProvider: PaymentMethodProvider
    
    private var schema: AWXSchema?
    private var bankSelectionViewModel: BankSelectionViewModel?
    private var bankList: [AWXBank]?
    private var task: Task<Void, Never>?
    
    private var uiFieldViewModels = [ String: InfoCollectorTextFieldViewModel ]()
    
    init(sectionType: PaymentSectionType, methodProvider: PaymentMethodProvider) {
        self.section = sectionType
        self.methodProvider = methodProvider
        super.init()
        self.prepareItemUpdates()
    }
    
    // MARK: - SectionController
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    let section: PaymentSectionType
    
    var items: [String] {
        var items = [String]()
        
        if let bankField = schema?.bankField {
            items.append(Item.bankSelection)
        }
        
        if let uiFields = schema?.uiFields {
            items.append(contentsOf: uiFields.map { $0.name })
        }
        
        items.append(Item.redirectRemider)
        items.append(Item.checkoutButton)
        return items
    }
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerReusableCell(CheckoutButtonCell.self)
        collectionView.registerReusableCell(SchemaPaymentRemiderCell.self)
        collectionView.registerReusableCell(BankSelectionCell.self)
        collectionView.registerReusableCell(InfoCollectorCell.self)
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
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case Item.checkoutButton:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckoutButtonCell.reuseIdentifier, for: indexPath) as! CheckoutButtonCell
            cell.setup(CheckoutButtonCellViewModel(checkoutAction: checkout))
            return cell
        case Item.redirectRemider:
            return collectionView.dequeueReusableCell(withReuseIdentifier: SchemaPaymentRemiderCell.reuseIdentifier, for: indexPath)
        case Item.bankSelection:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BankSelectionCell.reuseIdentifier, for: indexPath) as! BankSelectionCell
            if let bankSelectionViewModel {
                cell.setup(bankSelectionViewModel)
            } else {
                bankSelectionViewModel = BankSelectionViewModel(
                    bank: bankList?.first,
                    handleUserInteraction: { [weak self] in
                        self?.handleBankSelection()
                    }
                )
                cell.setup(bankSelectionViewModel!)
            }
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InfoCollectorCell.reuseIdentifier, for: indexPath) as! InfoCollectorCell
            if let viewModel = uiFieldViewModels[item] {
                cell.setup(viewModel)
            } else {
                guard let field = schema?.uiFields.first(where: { $0.name == item }) else {
                    assert(false, "field should exist")
                    return cell
                }
                let viewModel = InfoCollectorTextFieldViewModel(
                    title: field.displayName,
                    textFieldType: field.textFieldType,
                    triggerLayoutUpdate: { [weak self] in
                        self?.context.invalidateLayout(for: [item])
                    }
                )
                if field.uiType == AWXField.UIType.phone {
                    // TODO: optimize this
                    let a = AWXPaymentFormViewModel(
                        session: session,
                        paymentMethod: AWXPaymentMethod(),
                        formMapping: AWXFormMapping()
                    )
                    if let prefix = a.phonePrefix(), !prefix.isEmpty {
                        viewModel.text = prefix + " "
                    }
                }
                uiFieldViewModels[item] = viewModel
                cell.setup(viewModel)
            }
            return cell
        }
    }
    
    func prepareItemUpdates() {
        // TODO: optimize this
        if schema == nil && task == nil {
            task = Task {
                do {
                    let (schema, bankList) = try await self.getSchemaForPaymentMethod()
                    self.schema = schema
                    self.bankList = bankList
                    
                    var snapshot = self.context.currentSnapshot()
                    let items = snapshot.itemIdentifiers(inSection: section)
                    snapshot.deleteItems(items)
                    snapshot.appendItems(self.items)
                    self.context.applySnapshot(snapshot)
                    task = nil
                } catch {
                    schema = nil
                    bankList = nil
                    task = nil
                    guard let error = error as? String else { return }
                    showAlert(error)
                    debugLog("Failed to get fields for selected method. Error: \(error)")
                }
            }
        }
    }
    
    func getSchemaForPaymentMethod() async throws -> (AWXSchema, [AWXBank]?)  {
        let response = try await methodProvider.getPaymentMethodTypeDetails(name: methodType.name)
        let schema = response.schemas.first { $0.transactionMode == session.transactionMode() }
        guard let schema, !schema.fields.isEmpty else {
            throw NSLocalizedString("Invalid schema", bundle: .payment, comment: "")
        }
        
        var bankList: [AWXBank]?
        if let bankField = schema.bankField {
            let banks = try await methodProvider.getBankList().items
            guard !banks.isEmpty else {
                throw NSLocalizedString("Invalid schema", bundle: .payment, comment: "")
            }
            bankList = banks
        }
        return (schema, bankList)
    }
}

private extension SchemaPaymentSectionController {
    func checkout() {
        guard let schema else {
            // check schema
            prepareItemUpdates()
            return
        }
        
        do {
            // validate bank selection
            try bankSelectionViewModel?.validate()
            
            // validate uiFields
            for (_, viewModel) in uiFieldViewModels {
                try viewModel.validateUserInput(viewModel.text)
            }
            
            let paymentMethod = AWXPaymentMethod()
            paymentMethod.type = methodType.name
            
            //  update UI fields
            let inputContents = uiFieldViewModels.reduce(into: [String: String]()) { partialResult, kvTuple in
                partialResult[kvTuple.key] = kvTuple.value.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            paymentMethod.appendAdditionalParams(inputContents)
            
            // update hidden fields
            paymentMethod.appendAdditionalParams(parametersForHiddenFields(schema: schema))
            paymentSessionHandler = PaymentUISessionHandler(
                session: session,
                methodType: methodType,
                viewController: context.viewController!
            )
            paymentSessionHandler?.startPayment(paymentMethod)
            
            AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button")
            debugLog("Start payment. Intent ID: \(session.paymentIntentId() ?? "")")
        } catch {
            guard let error = error as? String else { return }
            showAlert(error)
            
            bankSelectionViewModel?.handleDidEndEditing()
            for (_, value) in uiFieldViewModels {
                value.handleDidEndEditing()
            }
            context.reload(sections: [section])
        }
    }
    
    func parametersForHiddenFields(schema: AWXSchema) -> [String: String] {
        let fields = schema.fields.filter { $0.hidden }
        var params = [String: String]()
        // flow
        if let flowField = fields.first(where: { $0.name == AWXField.Name.flow }) {
            if flowField.candidates.contains(where: { $0.value == AWXPaymentMethodFlow.app.rawValue }) {
                params[AWXField.Name.flow] = AWXPaymentMethodFlow.app.rawValue
            } else {
                params[AWXField.Name.flow] = flowField.candidates.first?.value
            }
        }
        // osType
        if let osTypeField = fields.first(where: { $0.name == AWXField.Name.osType }) {
            params[AWXField.Name.osType] = "ios"
        }
        // country_code
        if let countryCodeField = fields.first(where: { $0.name == AWXField.Name.country_code }) {
            params[AWXField.Name.country_code] = session.countryCode
        }
        
        return params
    }
    
    func handleBankSelection() {
        guard let bankList = bankList else { return }
        let formMapping = AWXFormMapping()
        formMapping.title = NSLocalizedString("Select your Bank", bundle: .payment, comment: "")
        formMapping.forms = bankList.map { bank in
            let form = AWXForm.init(key: bank.name, type: .listCell, title: bank.displayName, logo: bank.resources.logoURL)
            return form
        }
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
        paymentFormViewController.dismiss(animated: true) {
            self.context.reload(items: [ Item.bankSelection] )
        }
    }
}
