//
//  PaymentMethodsViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine
#if canImport(Core)
import Core
#endif

enum PaymentSectionType: Hashable {
    case listTitle
    case applePay
    case methodList
    case cardPaymentConsent
    case cardPaymentNew
    case schemaPayment(String)
}

class PaymentMethodsViewController: AWXViewController {
    
    let methodProvider: PaymentMethodProvider
    
    init(methodProvider: PaymentMethodProvider) {
        self.methodProvider = methodProvider
        super.init(nibName: nil, bundle: nil)
        self.session = methodProvider.session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if AWXUIContext.shared().paymentUIDismissAction != nil {
            // user cancel payment by navigation stack interactions, like screen edge pan gesture
            AWXUIContext.shared().paymentUIDismissAction = nil
            AnalyticsLogger.log(action: .paymentCanceled)
            AWXUIContext.shared().delegate?.paymentViewController(nil, didCompleteWith: .cancel, error: nil)
        }
    }
    
    private lazy var collectionViewManager: CollectionViewManager = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getMethodList()
        cancellable = methodProvider.updatePublisher.sink {[weak self] type in
            self?.collectionViewManager.performUpdates()
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
            let image = UIImage(named: "close", in: Bundle.resource())?
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
    }
    
    @objc func onCloseButtonTapped() {
        dismiss(animated: true) {
            AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
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
                    if let action = AWXUIContext.shared().paymentUIDismissAction {
                        action {
                            AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .failure, error: error)
                        }
                        AWXUIContext.shared().paymentUIDismissAction = nil
                    } else {
                        AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .failure, error: error)
                    }
                }
            }
        }
    }
    
    override func activeScrollView() -> UIScrollView {
        return collectionViewManager.collectionView
    }
}


extension PaymentMethodsViewController: AWXPageViewTrackable {
    var pageName: String! {
        "payment_method_list"
    }
}

extension PaymentMethodsViewController: CollectionViewSectionProvider {
    
    private var singleNonApplePayPaymentMethodAvailable: Bool {
        !methodProvider.isApplePayAvailable && methodProvider.methods.count == 1
    }
    
    private var displayMethodList: Bool {
        return methodProvider.methods.count > 1
    }
    
    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        //  title of the list
        sections.append(.listTitle)
        
        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }

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
            let layout = NSCollectionLayoutSection(group: group)
            layout.contentInsets = .init(top: 32, leading: 16, bottom: 8, trailing: 16)
            
            let controller = SimpleSectionController(
                section: PaymentSectionType.listTitle,
                item: "list_title",
                layout: layout) { [weak self] context, item, indexPath in
                    guard let self else { return UICollectionViewCell() }
                    let cell = context.dequeueReusableCell(LabelCell.self, for: item, indexPath: indexPath)
                    if self.singleNonApplePayPaymentMethodAvailable {
                        cell.label.text = self.methodProvider.selectedMethod?.displayName
                    } else {
                        cell.label.text = NSLocalizedString("Payment Methods", bundle: .payment, comment: "title for payment sheet")
                    }
                    return cell
                }
            return controller.anySectionController()
        case .applePay:
            let controller = ApplePaySectionController(
                session: methodProvider.session,
                methodType: methodProvider.applePayMethodType!
            )
            return controller.anySectionController()
        case .methodList:
            let controller = PaymentMethodListSectionController(
                methodProvider: methodProvider
            )
            return controller.anySectionController()
        case .cardPaymentConsent:
            let controller = CardPaymentConsentSectionController(
                methodProvider: methodProvider,
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
                switchToConsentPaymentAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = true
                    self.collectionViewManager.performUpdates()
                }
            ).anySectionController()
            return controller
        case .schemaPayment(let name):
            let controller = SchemaPaymentSectionController(
                name: name,
                methodProvider: methodProvider
            ).anySectionController()
            return controller
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        return nil
    }
}

