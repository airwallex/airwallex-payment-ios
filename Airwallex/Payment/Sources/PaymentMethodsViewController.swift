//
//  PaymentMethodsViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import Combine

class PaymentMethodsViewController: AWXViewController {
    
    static let collectionHeaderElementKind = "collection-header-element-kind"
    
    let methodProvider: PaymentMethodProvider
    private var paymentUISession: PaymentSessionHandler?
    private var selectedMethod: String? = nil
    
    init(methodProvider: PaymentMethodProvider) {
        self.methodProvider = methodProvider
        super.init(nibName: nil, bundle: nil)
        self.session = methodProvider.session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        AWXUIContext.shared().paymentUIDismissAction = nil
    }
    
    private lazy var collectionViewManager: CollectionViewManager = {
        let listConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        listConfiguration.interSectionSpacing = .spacing_16
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
        cancellable = methodProvider.updatePublisher.sink {[weak self] _ in
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
    
    @objc public func onCloseButtonTapped() {
        dismiss(animated: true) {
            AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
        }
    }
    
    @objc private func getMethodList(_ sender: UIRefreshControl? = nil) {
        Task {
            if let sender {
                sender.endRefreshing()
            }
            startAnimating()
            do {
                try await methodProvider.fetchPaymentMethods()
            } catch {
                showAlert(message: error.localizedDescription)
            }
            stopAnimating()
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
    
    var singleNonApplePayPaymentMethodAvailable: Bool {
        !methodProvider.isApplePayAvailable && methodProvider.methods.count == 1
    }
    
    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        //  title of the list
        sections.append(.listTitle)
        
        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }

        if !singleNonApplePayPaymentMethodAvailable {
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
                heightDimension: .estimated(44)
            )
            let item = NSCollectionLayoutItem(layoutSize: layoutSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
            let layout = NSCollectionLayoutSection(group: group)
            layout.contentInsets = .init(top: 32, leading: 16, bottom: 8, trailing: 16)
            
            let controller = SimpleSectionController(
                section: .listTitle,
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
        case .schemaPayment(_):
            let controller = SchemaPaymentSectionController(
                sectionType: section,
                methodProvider: methodProvider
            ).anySectionController()
            return controller
        default:
            fatalError("unexpected section")
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        return nil
    }
}

enum PaymentSectionType: Hashable {
    case listTitle
    case applePay
    case methodList
    case cardPaymentConsent
    case cardPaymentNew
    case schemaPayment(String)
}


