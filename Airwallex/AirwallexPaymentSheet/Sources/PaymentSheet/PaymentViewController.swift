//
//  PaymentViewController.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Combine
import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
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
    /// The originally configured layout, before any fallback logic is applied.
    private(set) var layout: AWXUIContext.PaymentLayout

    let paymentUIContext: PaymentSheetUIContext

    init(methodProvider: PaymentMethodProvider,
         paymentUIContext: PaymentSheetUIContext) {
        self.methodProvider = methodProvider
        self.paymentUIContext = paymentUIContext
        self.layout = paymentUIContext.layout
        super.init(nibName: nil, bundle: nil)
        self.session = methodProvider.session
        self.paymentUIContext.viewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Task { @MainActor [paymentUIContext] in
            if paymentUIContext.dismissAction != nil {
                await paymentUIContext.completePaymentSession()
                // this fallback logic handles user cancel payment by navigation stack interactions
                // e.g. screen edge pan gesture
                AnalyticsLogger.log(action: .paymentCanceled)
                paymentUIContext.delegate?.paymentViewController(nil, didCompleteWith: .cancel, error: nil)
            }
        }
    }
    
    private(set) lazy var collectionViewManager: CollectionViewManager = {
        let listConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        listConfiguration.interSectionSpacing = 16
        let manager = CollectionViewManager(
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
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        
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
            self.paymentUIContext.delegate?.paymentViewController(self, didCompleteWith: .cancel, error: nil)
        }
    }
    
    @objc private func getMethodList(_ sender: UIRefreshControl? = nil) {
        Task {
            startLoading()
            do {
                try await methodProvider.getPaymentMethodTypes()
                stopLoading()
                if let sender {
                    sender.endRefreshing()
                }
            } catch {
                debugLog("failed to get payment method list: \(error)")
                showAlert(message: error.localizedDescription) { _ in
                    guard self.methodProvider.methods.isEmpty else {
                        return
                    }
                    Task {
                        await self.paymentUIContext.completePaymentSession()
                        self.paymentUIContext.delegate?.paymentViewController(self, didCompleteWith: .failure, error: error)
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
        AnalyticEvent.PageView.paymentMethodList.rawValue
    }
}

extension PaymentViewController: CollectionViewSectionProvider {
    
    private var listTitle: String {
        let defaultTitle = NSLocalizedString("Payment Methods", bundle: .paymentSheet, comment: "title for payment sheet")
        if methodProvider is SinglePaymentMethodProvider {
            // Single-method: use the selected method name instead of the generic list title.
            return methodProvider.selectedMethod?.displayName ?? defaultTitle
        }
        // Payment sheet:
        if methodProvider.methods.count == 1,
              let selectedMethod = methodProvider.selectedMethod,
              selectedMethod.name == AWXCardKey,
              methodProvider.consents.isEmpty {
            // Use the display name only when Add New Card is the only option available.
            return selectedMethod.displayName
        }
        return defaultTitle
    }

    private var displayMethodTab: Bool {
        guard !(methodProvider is SinglePaymentMethodProvider) else {
            // Never display method tab for SinglePaymentMethodProvider
            return false
        }

        // Payment sheet:
        guard useTabLayout, methodProvider.methods.count > 0 else {
            return false
        }

        if methodProvider.methods.count == 1 {
            // Single payment method available
            let methodName = methodProvider.selectedMethod?.name ?? ""
            // hide method tab when only apple pay or add card available
            switch methodName {
            case AWXApplePayKey:
                return false
            case AWXCardKey:
                return !methodProvider.consents.isEmpty
            default:
                return true
            }
        } else {
            // Display payment method tab when multiple payment methods are available
            return true
        }
    }
    
    private var useTabLayout: Bool {
        layout == .tab || (methodProvider.methods.count <= 1 + (methodProvider.isApplePayAvailable ? 1 : 0))
    }
    
    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        //  title of the list
        sections.append(.listTitle)
        
        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }
        
        if useTabLayout {
            if displayMethodTab {
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
        } else {
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
        // Update paymentUIContext.layout to effective layout before creating section controllers
        paymentUIContext.layout = useTabLayout ? .tab : .accordion

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
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
        case .methodList:
            let controller = PaymentMethodTabSectionController(
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
        case .cardPaymentConsent:
            let controller = CardPaymentConsentSectionController(
                methodType: methodProvider.method(named: AWXCardKey)!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext,
                addNewCardAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = false
                    self.collectionViewManager.performUpdates()
                }
            )
            return controller.anySectionController()
        case .cardPaymentNew:
            let controller = NewCardPaymentSectionController(
                cardPaymentMethod: methodProvider.method(named: AWXCardKey)!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext,
                switchToConsentPaymentAction: { [weak self] in
                    guard let self else { return }
                    self.preferConsentPayment = true
                    self.collectionViewManager.performUpdates()
                }
            )
            return controller.anySectionController()
        case .schemaPayment(let name):
            let controller = SchemaPaymentSectionController(
                methodType: methodProvider.method(named: name)!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
        case .accordion(let position):
            let controller = AccordionSectionController(
                position: position,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
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
        guard let indexPath = collectionViewManager.collectionView.indexPathForItem(at: location) else {
            // not on a cell, begin gesture
            return true
        }
        // Tapped on a cell, do nothing
        return false
    }
}
