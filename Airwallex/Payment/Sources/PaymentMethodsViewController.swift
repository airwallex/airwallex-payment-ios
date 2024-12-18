//
//  PaymentMethodsViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

class PaymentMethodsViewController: AWXViewController {
    
    static let collectionHeaderElementKind = "collection-header-element-kind"
    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"
    
    enum Section: Int, Hashable, CaseIterable {
        case applePay
        case methodList
        @MainActor func items(methodProvider: PaymentMethodProvider) -> [String] {
            switch self {
            case .applePay:
                if let method = methodProvider.method(named: AWXApplePayKey) {
                    return [ method.name ]
                }
                return []
            case .methodList:
                let methods: [String] = methodProvider.methods.compactMap {
                    if $0.name == AWXApplePayKey {
                        return nil
                    } else {
                        return $0.name
                    }
                }
                return methods
            }
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(25)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: Self.collectionHeaderElementKind,
            alignment: .top
        )
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.boundarySupplementaryItems = [header]
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { sectionIndex, environment in
                guard let section = Section(rawValue: sectionIndex) else {
                    fatalError("section not exist")
                }
                switch section {
                case .applePay:
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(48)
                    )
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = .init(top: 24, leading: 16, bottom: 16, trailing: 16)
                    
                    let footerSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(22)
                    )
                    let footer = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: footerSize,
                        elementKind: Self.sectionFooterElementKind,
                        alignment: .bottom
                    )
                    section.boundarySupplementaryItems = [footer]
                    
                    return section
                case .methodList:
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .absolute(92),
                        heightDimension: .absolute(70)
                    )
                    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .continuous
                    section.contentInsets = .init(top: 24, leading: 16, bottom: 24, trailing: 16)
                    section.interGroupSpacing = 8
                    return section
                }
                
            },
            configuration: configuration
        )
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        startAnimating()
        
        Task {
            do {
                try await methodProvider.fetchPaymentMethods()
                
                configDataSource()
                var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
                snapshot.appendSections(Section.allCases)
                for section in Section.allCases {
                    // wpdebug
                    print(section)
                    let items = section.items(methodProvider: methodProvider)
                    // wpdebug
                    print(items)
                    snapshot.appendItems(items, toSection: section)
                }
                
                self.selectedMethod = methodProvider.methods.first?.name
                dataSource.apply(snapshot)
                stopAnimating()
            } catch {
                // TODO: log error
            }
        }
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
            action: #selector(foo)
        )
        navigationItem.title = "DEMO CHECKOUT"
        
        view.addSubview(collectionView)
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        collectionView.register(
            LabelHeader.self,
            forSupplementaryViewOfKind: Self.collectionHeaderElementKind,
            withReuseIdentifier: LabelHeader.reuseIdentifier
        )
        collectionView.register(
            ApplePayCell.self,
            forCellWithReuseIdentifier: String(describing: ApplePayCell.self)
        )
        collectionView.register(
            PaymentMethodCell.self,
            forCellWithReuseIdentifier: PaymentMethodCell.reuseIdentifier
        )
        collectionView.register(
            PaymentMethodListSeparator.self,
            forSupplementaryViewOfKind: Self.sectionFooterElementKind,
            withReuseIdentifier: PaymentMethodListSeparator.reuseIdentifier
        )
    }
    
    private func configDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self, let section = Section(rawValue: indexPath.section) else { fatalError("section not found") }
            switch section {
            case .applePay:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ApplePayCell.reuseIdentifier,
                    for: indexPath
                ) as! ApplePayCell
                
                let viewModel = ApplePayViewModel {
                    guard let paymentSessionHandler = PaymentUISessionHandler(
                        session: self.methodProvider.session,
                        methodType: self.methodProvider.method(named: AWXApplePayKey)!,
                        viewController: self
                    ) else { return }
                    
                    self.paymentUISession = paymentSessionHandler
                    paymentSessionHandler.startPayment()
                }
                
                cell.setup(viewModel)
                return cell
            case .methodList:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PaymentMethodCell.reuseIdentifier,
                    for: indexPath
                ) as! PaymentMethodCell
                
                guard let methodType = self.methodProvider.method(named: itemIdentifier) else {
                    assert(false, "method type not found for \(itemIdentifier)")
                    return cell
                }
                
                let viewModel = PaymentMethodCellViewModel(
                    name: methodType.displayName,
                    imageURL: methodType.resources.logoURL,
                    isSelected: itemIdentifier == self.selectedMethod
                )
                cell.setup(viewModel)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = {(collectionView, elementKind, indexPath) in
            if elementKind == Self.collectionHeaderElementKind {
                return collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: LabelHeader.reuseIdentifier,
                    for: indexPath
                )
            }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("section not found") }
            switch section {
            case .applePay:
                return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: PaymentMethodListSeparator.reuseIdentifier, for: indexPath)
            default:
                return nil
            }
        }
    }
    
    @objc
    public func foo() {
        AWXUIContext.shared().delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
    }
}


extension PaymentMethodsViewController: AWXPageViewTrackable {
    var pageName: String! {
        "payment_method_list"
    }
}


extension PaymentMethodsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard Section(rawValue: indexPath.section) == .methodList,
              let item = dataSource.itemIdentifier(for: indexPath),
              let methodType = methodProvider.method(named: item) else {
            return
        }
        
        selectedMethod = item
        
        var snapshot = dataSource.snapshot()
        let identifiers = snapshot.itemIdentifiers(inSection: .methodList)
        snapshot.reloadItems(identifiers)
        dataSource.apply(snapshot)

        // TODO: update UI or start payment
        
        
        AWXAnalyticsLogger().logAction(withName: "select_payment", additionalInfo: [ "paymentMethod": methodType.name ])
    }
}
