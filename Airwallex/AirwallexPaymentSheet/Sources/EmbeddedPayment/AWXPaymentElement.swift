//
//  AWXPaymentElement.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/1/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Combine
import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
@_spi(AWX) import AirwallexPayment
#endif

/// An embeddable payment element that can be added to any view hierarchy.
///
/// `AWXPaymentElement` provides a flexible way to integrate Airwallex payment UI into your app.
/// Unlike `AWXUIContext.launchPayment()` which presents a full payment sheet as a view controller,
/// `AWXPaymentElement` returns a `UIView` that you can embed in your own view hierarchy.
///
/// ## Usage
/// ```swift
/// let configuration = AWXPaymentElement.Configuration()
/// configuration.layout = .accordion
///
/// let element = try await AWXPaymentElement.create(
///     hostViewController: self,
///     session: session,
///     delegate: self,
///     configuration: configuration
/// )
/// containerView.addSubview(element.view)
/// ```
///
/// ## Important Notes
/// - The embedded view requires Auto Layout constraints for proper sizing
/// - The view's height updates automatically based on content
/// - A host view controller is required for presenting modals (3DS, redirects, etc.)
/// - Keyboard handling is the host app's responsibility
@MainActor
@objc
public class AWXPaymentElement: NSObject {

    private let subtype = "embedded_element"

    /// The embeddable view containing the payment UI.
    ///
    /// Add this view to your view hierarchy using Auto Layout constraints.
    /// The view's height will update automatically based on its content.
    @objc public var view: UIView { embeddedView }

    /// The delegate that receives payment result callbacks.
    @objc public weak var delegate: AWXPaymentResultDelegate? {
        didSet {
            paymentUIContext.delegate = delegate
        }
    }

    // MARK: - Private Properties

    private weak var hostViewController: UIViewController?
    private let methodProvider: PaymentMethodProvider
    let paymentUIContext = PaymentSheetUIContext()
    private lazy var collectionViewManager: CollectionViewManager = {
        let listConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        listConfiguration.interSectionSpacing = 16
        let manager = CollectionViewManager(
            viewController: hostViewController!,
            sectionProvider: self,
            listConfiguration: listConfiguration
        )
        return manager
    }()
    private lazy var embeddedView: EmbeddedPaymentView = {
        EmbeddedPaymentView(collectionView: collectionViewManager.collectionView)
    }()
    private var cancellable: AnyCancellable?
    private var preferConsentPayment = true
    private let configuration: Configuration

    // MARK: - Initialization

    /// Creates an embedded payment element.
    ///
    /// This factory method validates the session, fetches available payment methods,
    /// and creates a fully configured payment element.
    ///
    /// - Parameters:
    ///   - hostViewController: The view controller that will host this element.
    ///     Used for presenting modals like 3DS authentication, redirects, and country selection.
    ///   - session: The payment session containing transaction details.
    ///   - delegate: The delegate that receives payment result callbacks.
    ///   - configuration: Configuration options for the payment element.
    /// - Returns: A configured `AWXPaymentElement` ready to be embedded.
    /// - Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
    @objc
    public static func create(
        hostViewController: UIViewController,
        session: AWXSession,
        delegate: AWXPaymentResultDelegate,
        configuration: Configuration = Configuration()
    ) async throws -> AWXPaymentElement {
        let methodProvider = try makeMethodProvider(session: session, configuration: configuration)

        return try await create(
            hostViewController: hostViewController,
            session: session,
            methodProvider: methodProvider,
            delegate: delegate,
            configuration: configuration
        )
    }

    static func makeMethodProvider(
        session: AWXSession,
        configuration: Configuration
    ) throws -> PaymentMethodProvider {
        switch configuration.elementType {
        case .standard:
            return PaymentSheetMethodProvider(session: session)
        case .addCard:
            guard !configuration.supportedCardBrands.isEmpty else {
                throw AWXUIContext.LaunchError.invalidCardBrand("supportedBrands should not be empty")
            }
            guard Set(configuration.supportedCardBrands).isSubset(of: AWXCardBrand.allAvailable) else {
                throw AWXUIContext.LaunchError.invalidCardBrand("make sure you only include card brands defined in AWXCardBrand")
            }
            return SinglePaymentMethodProvider(
                session: session,
                name: AWXCardKey,
                supportedCardBrands: configuration.supportedCardBrands
            )
        }
    }
    
    static func create(
        hostViewController: UIViewController,
        session: AWXSession,
        methodProvider: PaymentMethodProvider,
        delegate: AWXPaymentResultDelegate,
        configuration: Configuration = Configuration()
    ) async throws -> AWXPaymentElement {
        // Validate session
        do {
            try session.validate()
        } catch {
            throw AWXUIContext.LaunchError.invalidSession(underlyingError: error)
        }

        // Update logger.session for embedded integration
        AnalyticsLogger.shared().session = session

        // fetch payment methods using method provider
        try await methodProvider.getPaymentMethodTypes()

        // Risk event
        RiskLogger.log(.transactionInitiated)

        // Create element with all dependencies ready
        let element = AWXPaymentElement(
            hostViewController: hostViewController,
            methodProvider: methodProvider,
            delegate: delegate,
            configuration: configuration
        )

        // Analytics
        var extraInfo: [AnalyticEvent.Fields: Any] = [
            .subtype: element.subtype,
            .expressCheckout: session.isExpressCheckout
        ]
        if configuration.elementType == .addCard {
            extraInfo[.paymentMethod] = AWXCardKey
        }
        AnalyticsLogger.log(action: .paymentLaunched, extraInfo: extraInfo)

        return element
    }

    init(
        hostViewController: UIViewController,
        methodProvider: PaymentMethodProvider,
        delegate: AWXPaymentResultDelegate,
        configuration: Configuration = Configuration()
    ) {
        self.hostViewController = hostViewController
        self.methodProvider = methodProvider
        self.delegate = delegate
        self.configuration = configuration
        super.init()

        // Now set the internal delegate and viewController
        self.paymentUIContext.delegate = delegate
        self.paymentUIContext.viewController = hostViewController
        self.paymentUIContext.isEmbedded = true
        self.paymentUIContext.layout = configuration.layout

        // Configure collection view
        let collectionView = collectionViewManager.collectionView!
        collectionView.backgroundColor = .awxColor(.backgroundPrimary)

        // Subscribe to method provider updates
        cancellable = methodProvider.updatePublisher.sink { [weak self] _ in
            self?.collectionViewManager.performUpdates(animatingDifferences: true)
        }

        // Trigger initial data load
        collectionViewManager.performUpdates()
    }
}

// MARK: - CollectionViewSectionProvider

extension AWXPaymentElement: CollectionViewSectionProvider {

    private var displayMethodList: Bool {
        return paymentUIContext.layout == .tab && methodProvider.methods.count > (methodProvider.isApplePayAvailable ? 1 : 0)
    }

    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()

        // For card element type, only show new card payment (no consents, no method list)
        if configuration.elementType == .addCard {
            sections.append(.cardPaymentNew)
            return sections
        }

        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }

        switch paymentUIContext.layout {
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
        case .methodList:
            let controller = PaymentMethodTabSectionController(
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            return controller.anySectionController()
        case .applePay:
            let controller = ApplePaySectionController(
                session: methodProvider.session,
                methodType: methodProvider.applePayMethodType!,
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
                    self.collectionViewManager.performUpdates(animatingDifferences: true)
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
                    self.collectionViewManager.performUpdates(animatingDifferences: true)
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
        default:
            debugLog("section not expected: \(section)")
            let layoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: layoutSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
            let sectionLayout = NSCollectionLayoutSection(group: group)
            
            let controller = SimpleSectionController(
                section: PaymentSectionType.listTitle,
                item: UUID().uuidString,
                layout: sectionLayout
            ) { _, _, _ in
                return UICollectionViewCell()
            }
            return controller.anySectionController()
        }
    }

    func listBoundaryItemProviders() -> [BoundarySupplementaryItemProvider]? {
        return nil
    }
}
