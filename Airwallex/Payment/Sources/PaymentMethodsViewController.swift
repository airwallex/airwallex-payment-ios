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
    
    private var token: AnyCancellable?
    
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
        
        token = methodProvider.publisher.sink {[weak self] _ in
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
        let image = UIImage(named: "close", in: Bundle.resource())?
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.awxIconPrimary, renderingMode: .alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(onCloseButtonTapped)
        )
        navigationItem.title = "DEMO CHECKOUT"
        
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
                sections.append(.cardPaymentNew)
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
                methodProvider: methodProvider
            )
            return controller.anySectionController()
        case .cardPaymentNew:
            let controller = NewCardPaymentSectionController(
                section: section,
                methodType: methodProvider.selectedMethod!
            ).anySectionController()
            return controller
        default:
            fatalError("unexpected section")
        }
    }
    
    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(25)
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
