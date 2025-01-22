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
    private var paymentUISession: PaymentUISessionHandler?
    private var selectedMethod: String? = nil
    
    init(methodProvider: PaymentMethodProvider) {
        self.methodProvider = methodProvider
        super.init(nibName: nil, bundle: nil)
        self.session = methodProvider.session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var sectionProvider: CollectionViewManager = {
        let provider = CollectionViewManager(
            viewController: self,
            sectionProvider: self
        )
        return provider
    }()
    
    private var cancellable: AnyCancellable?
    
    private var preferConsentPayment = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        startAnimating()
        
        Task {
            do {
                try await methodProvider.fetchPaymentMethods()
                
                sectionProvider.reloadData()
                stopAnimating()
            } catch {
                
            }
        }
        
        cancellable = methodProvider.publisher.sink {[weak self] _ in
            self?.sectionProvider.reloadData()
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
        view.backgroundColor = AWXTheme.shared().primaryBackgroundColor()
        if navigationController?.viewControllers.first === self {
            let image = UIImage(named: "close", in: Bundle.resource())?
                .withTintColor(.awxIconPrimary, renderingMode: .alwaysTemplate)
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(onCloseButtonTapped)
            )
        }
        
        let collectionView = sectionProvider.collectionView!
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
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
        AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
    }
    
    override func activeScrollView() -> UIScrollView {
        return sectionProvider.collectionView
    }
}


extension PaymentMethodsViewController: AWXPageViewTrackable {
    var pageName: String! {
        "payment_method_list"
    }
}

extension PaymentMethodsViewController: CollectionViewSectionProvider {
    
    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }
        // horizontal list
        sections.append(.methodList)
        
        if let selectedMethodType = methodProvider.selectedMethod {
            if selectedMethodType.name == "card" {
                if preferConsentPayment && !methodProvider.consents.isEmpty {
                    sections.append(.cardPaymentConsent)
                } else {
                    sections.append(.cardPaymentNew)
                }
            }
        }
        return sections
    }
    
    func sectionController(for section: PaymentSectionType) -> AnySectionController<PaymentSectionType, String> {
        switch section {
        case .applePay:
            let controller = ApplePaySectionController(
                session: methodProvider.session,
                methodType: methodProvider.applePayMethodType!,
                viewController: self
            )
            return controller.anySectionController()
        case .methodList:
            let controller = PaymentMethodListSectionController(
                section: section,
                methodTypes: methodProvider.methods.filter({ $0.name != AWXApplePayKey }),
                session: methodProvider.session
            )
            return controller.anySectionController()
        case .cardPaymentConsent:
            let controller = CardPaymentConsentSectionController(
                session: methodProvider.session,
                section: section,
                methodProvider: methodProvider,
                addNewCardAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = false
                    self.sectionProvider.reloadData()
                }
            )
            return controller.anySectionController()
        case .cardPaymentNew:
            let controller = NewCardPaymentSectionController(
                section: section,
                methodType: methodProvider.selectedMethod!,
                methodProvider: methodProvider,
                switchToConsentPaymentAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = true
                    self.sectionProvider.reloadData()
                }
            ).anySectionController()
            return controller
        default:
            fatalError("unexpected section")
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(65)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: Self.collectionHeaderElementKind,
            alignment: .top
        )
        return [BoundarySupplementaryItemProvider(
            elementKind: Self.collectionHeaderElementKind,
            layout: header,
            reusableView: LabelHeader.self
        )]
    }
}

enum PaymentSectionType: Hashable {
    case applePay
    case methodList
    case cardPaymentConsent
    case cardPaymentNew
}
