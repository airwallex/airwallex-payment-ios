//
//  PaymentViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

enum PaymentSectionType: Hashable {
    case listTitle
    case applePay
    case methodList
    case cardPaymentConsent
    case cardPaymentNew
    case schemaPayment(String)
    case accordion(AccordionSectionController.Position)
}

class PaymentViewController: AWXViewController {
    
    let methodProvider: PaymentMethodProvider
    
    private(set) var layout: AWXUIContext.PaymentLayout
    
    init(methodProvider: PaymentMethodProvider,
         layout: AWXUIContext.PaymentLayout = .tab) {
        self.methodProvider = methodProvider
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
        self.session = methodProvider.session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Task { @MainActor in
            if AWXUIContext.shared.dismissAction != nil {
                // user cancel payment by navigation stack interactions, like screen edge pan gesture
                AWXUIContext.shared.dismissAction = nil
                AnalyticsLogger.log(action: .paymentCanceled)
                AWXUIContext.shared.delegate?.paymentViewController(nil, didCompleteWith: .cancel, error: nil)
            }
        }
    }
    
    private(set) lazy var collectionViewManager: CollectionViewManager = {
        let listConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        listConfiguration.interSectionSpacing = 16
        let manager = CollectionViewManager(
            viewController: self,
            sectionProvider: self,
            listConfiguration: listConfiguration
        )
        return manager
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(getMethodList(_:)), for: .valueChanged)
        return view
    }()
    
    private var cancellable: AnyCancellable?
    
    private var preferConsentPayment = true
    
    private lazy var imageLoader = ImageLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getMethodList()
        cancellable = methodProvider.updatePublisher.sink {[weak self] type in
            guard let self else { return }
            var animating = self.layout == .accordion
            if case PaymentMethodProviderUpdateType.consentDeleted(_) = type {
                animating = true
            }
            self.collectionViewManager.performUpdates(animatingDifferences: animating)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterKeyboard()
    }
    
    private func setupUI() {
        self.navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .awxColor(.backgroundPrimary)
        if navigationController?.viewControllers.first === self {
            let image = UIImage(named: "close", in: .paymentSheet)?
                .withTintColor(.awxColor(.iconPrimary), renderingMode: .alwaysTemplate)
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(onCloseButtonTapped)
            )
        }
        
        let collectionView = collectionViewManager.collectionView!
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.backgroundColor = .awxColor(.backgroundPrimary)
        collectionView.refreshControl = refreshControl
        
        view.addSubview(collectionView)
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        // dismiss keyboard when user tap on empty space in collection view
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapGesture))
        tap.delegate = self
        collectionView.addGestureRecognizer(tap)
    }
    
    @objc func onCloseButtonTapped() {
        dismiss(animated: true) {
            AWXUIContext.shared.delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
        }
    }
    
    @objc private func getMethodList(_ sender: UIRefreshControl? = nil) {
        Task {
            startAnimating()
            do {
                try await methodProvider.getPaymentMethodTypes()
                stopAnimating()
                if let sender {
                    sender.endRefreshing()
                }
            } catch {
                debugLog("failed to get payment method list: \(error)")
                showAlert(message: error.localizedDescription) { _ in
                    guard self.methodProvider.methods.isEmpty else {
                        return
                    }
                    if let action = AWXUIContext.shared.dismissAction {
                        action {
                            AWXUIContext.shared.delegate?.paymentViewController(self, didCompleteWith: .failure, error: error)
                        }
                        AWXUIContext.shared.dismissAction = nil
                    } else {
                        AWXUIContext.shared.delegate?.paymentViewController(self, didCompleteWith: .failure, error: error)
                    }
                }
            }
        }
    }
    
    override func activeScrollView() -> UIScrollView {
        return collectionViewManager.collectionView
    }
}


extension PaymentViewController: AWXPageViewTrackable {
    var pageName: String! {
        "payment_method_list"
    }
}

extension PaymentViewController: CollectionViewSectionProvider {
    
    private var listTitle: String {
        let defaultTitle = NSLocalizedString("Payment Methods", bundle: .paymentSheet, comment: "title for payment sheet")
        guard methodProvider.methods.count == 1 else {
            return defaultTitle
        }
        if methodProvider.isApplePayAvailable {
            return methodProvider.applePayMethodType?.displayName ?? defaultTitle
        } else {
            return methodProvider.selectedMethod?.displayName ?? defaultTitle
        }
    }
    
    private var displayMethodList: Bool {
        return layout == .tab && methodProvider.methods.count > 1 + (methodProvider.isApplePayAvailable ? 1 : 0)
    }
    
    private var fallbackToTabLayout: Bool {
        methodProvider.methods.count <= 1 + (methodProvider.isApplePayAvailable ? 1 : 0)
    }
    
    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        //  title of the list
        sections.append(.listTitle)
        
        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }
        
        switch layout {
        case .tab:
            if displayMethodList {
                // horizontal list
                sections.append(.methodList)
            }
            //  display selected payment method
            if let selectedMethodType = methodProvider.selectedMethod {
                if selectedMethodType.name == AWXCardKey {
                    if preferConsentPayment && !methodProvider.consents.isEmpty {
                        sections.append(.cardPaymentConsent)
                    } else {
                        sections.append(.cardPaymentNew)
                    }
                } else if selectedMethodType.hasSchema {
                    sections.append(.schemaPayment(selectedMethodType.name))
                }
            }
        case .accordion:
            if !methodProvider.methodsForAccordionPosition(.top).isEmpty {
                sections.append(.accordion(.top))
            }
            
            if let selectedMethodType = methodProvider.selectedMethod {
                if selectedMethodType.name == AWXCardKey {
                    if preferConsentPayment && !methodProvider.consents.isEmpty {
                        sections.append(.cardPaymentConsent)
                    } else {
                        sections.append(.cardPaymentNew)
                    }
                } else if selectedMethodType.hasSchema {
                    sections.append(.schemaPayment(selectedMethodType.name))
                }
            }
            
            if !methodProvider.methodsForAccordionPosition(.bottom).isEmpty {
                sections.append(.accordion(.bottom))
            }
        }
        return sections
    }
    
    func sectionController(for section: PaymentSectionType) -> AnySectionController<PaymentSectionType, String> {
        switch section {
        case .listTitle:
            let layoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(20)
            )
            let item = NSCollectionLayoutItem(layoutSize: layoutSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 32, leading: 16, bottom: 8, trailing: 16)
            
            let controller = SimpleSectionController(
                section: PaymentSectionType.listTitle,
                item: "list_title",
                layout: section
            ) { [weak self] context, item, indexPath in
                guard let self else { return UICollectionViewCell() }
                let cell = context.dequeueReusableCell(LabelCell.self, for: item, indexPath: indexPath)
                cell.label.text = self.listTitle
                return cell
            }
            return controller.anySectionController()
        case .applePay:
            let controller = ApplePaySectionController(
                session: methodProvider.session,
                methodType: methodProvider.applePayMethodType!,
                methodProvider: methodProvider
            )
            return controller.anySectionController()
        case .methodList:
            let controller = PaymentMethodTabSectionController(
                methodProvider: methodProvider,
                imageLoader: imageLoader
            )
            return controller.anySectionController()
        case .cardPaymentConsent:
            let controller = CardPaymentConsentSectionController(
                methodType: methodProvider.method(named: AWXCardKey)!,
                methodProvider: methodProvider,
                layout: fallbackToTabLayout ? .tab : layout,
                imageLoader: imageLoader,
                addNewCardAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = false
                    self.collectionViewManager.performUpdates()
                }
            )
            return controller.anySectionController()
        case .cardPaymentNew:
            let controller = NewCardPaymentSectionController(
                cardPaymentMethod: methodProvider.selectedMethod!,
                methodProvider: methodProvider,
                layout: fallbackToTabLayout ? .tab : layout,
                imageLoader: imageLoader,
                switchToConsentPaymentAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = true
                    self.collectionViewManager.performUpdates()
                }
            ).anySectionController()
            return controller
        case .schemaPayment(let name):
            let controller = SchemaPaymentSectionController(
                methodType: methodProvider.method(named: name)!,
                methodProvider: methodProvider,
                layout: fallbackToTabLayout ? .tab : layout,
                imageLoader: imageLoader
            ).anySectionController()
            return controller
        case .accordion(let position):
            return AccordionSectionController(
                position: position,
                methodProvider: methodProvider,
                imageLoader: imageLoader
            ).anySectionController()
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        return nil
    }
}

extension PaymentViewController: UIGestureRecognizerDelegate {
    
    @objc func onTapGesture() {
        collectionViewManager.collectionView.endEditing(false)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: collectionViewManager.collectionView)
        guard let indexPath = collectionViewManager.collectionView.indexPathForItem(at: location) else  {
            // not on a cell, begin gesture
            return true
        }
        // Tapped on a cell, do nothing
        return false
    }
}
