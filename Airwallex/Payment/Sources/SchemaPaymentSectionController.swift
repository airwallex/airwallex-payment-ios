//
//  SchemaPaymentSectionController.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/1/10.
//  Copyright © 2025 Airwallex. All rights reserved.
//
import AirwallexRisk

class SchemaPaymentSectionController: SectionController {
    
    enum Item: String {
        case checkoutButton
        case redirectRemider
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
    
    init(sectionType: PaymentSectionType, methodProvider: PaymentMethodProvider) {
        self.section = sectionType
        self.methodProvider = methodProvider
    }
    
    // MARK: - SectionController
    
    private(set) var context: CollectionViewContext<PaymentSectionType, String>!
    
    var section: PaymentSectionType
    
    var items = [ Item.redirectRemider.rawValue, Item.checkoutButton.rawValue ]
    
    func bind(context: CollectionViewContext<PaymentSectionType, String>) {
        self.context = context
    }
    
    func registerReusableViews(to collectionView: UICollectionView) {
        collectionView.registerReusableCell(CheckoutButtonCell.self)
        collectionView.registerReusableCell(SchemaPaymentRemiderCell.self)
    }
    
    func layout(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(horizontal: .spacing_16)
        section.interGroupSpacing = .spacing_24
        return section
    }
    
    func cell(for collectionView: UICollectionView, item: String, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = Item(rawValue: item) else { fatalError("Invalid item") }
        switch item {
        case .checkoutButton:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckoutButtonCell.reuseIdentifier, for: indexPath) as! CheckoutButtonCell
            cell.setup(CheckoutButtonCellViewModel(checkoutAction: checkout))
            return cell
        case .redirectRemider:
            return collectionView.dequeueReusableCell(withReuseIdentifier: SchemaPaymentRemiderCell.reuseIdentifier, for: indexPath)
        default:
            fatalError()
        }
    }
}

private extension SchemaPaymentSectionController {
    func checkout() {
        AWXAnalyticsLogger.shared().logAction(withName: "tap_pay_button")
        debugLog("Start payment. Intent ID: \(session.paymentIntentId())")
        paymentSessionHandler = PaymentUISessionHandler(
            session: session,
            methodType: methodType,
            viewController: context.viewController!
        )
        paymentSessionHandler?.startPayment()
    }
}
