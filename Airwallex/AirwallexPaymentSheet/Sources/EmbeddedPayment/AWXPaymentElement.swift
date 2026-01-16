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
/// let element = try await AWXPaymentElement.create(
///     hostViewController: self,
///     session: session,
///     delegate: self,
///     layout: .tab
/// )
/// scrollView.addSubview(element.view)
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
    private let paymentUIContext = PaymentUIContext()
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
    private lazy var imageLoader = ImageLoader()

    // MARK: - Initialization

    /// Creates an embedded payment element.
    ///
    /// This factory method validates the session, fetches available payment methods,
    /// and creates a fully configured payment element.
    ///
    /// - Parameters:
    ///   - session: The payment session containing transaction details.
    ///   - hostViewController: The view controller that will host this element.
    ///     Used for presenting modals like 3DS authentication, redirects, and country selection.
    ///   - delegate: The delegate that receives payment result callbacks.
    /// - Returns: A configured `AWXPaymentElement` ready to be embedded.
    /// - Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
    @objc
    public static func create(
        session: AWXSession,
        hostViewController: UIViewController,
        delegate: AWXPaymentResultDelegate
    ) async throws -> AWXPaymentElement {
        try await create(
            session: session,
            methodProvider: PaymentSheetMethodProvider(session: session),
            hostViewController: hostViewController,
            delegate: delegate
        )
    }

    /// Creates an embedded payment element using a single view controller as both host and delegate.
    ///
    /// This is a convenience method for when your view controller conforms to `AWXPaymentResultDelegate`.
    ///
    /// - Parameters:
    ///   - session: The payment session containing transaction details.
    ///   - delegate: The view controller that will host this element and receive payment result callbacks.
    /// - Returns: A configured `AWXPaymentElement` ready to be embedded.
    /// - Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
    @objc
    public static func create(
        session: AWXSession,
        delegate: UIViewController & AWXPaymentResultDelegate
    ) async throws -> AWXPaymentElement {
        try await create(
            session: session,
            methodProvider: PaymentSheetMethodProvider(session: session),
            hostViewController: delegate,
            delegate: delegate
        )
    }

    /// Creates an embedded payment element with specific payment method
    ///
    /// This factory method validates the session, fetches available payment methods,
    /// and creates a fully configured payment element.
    ///
    /// - Parameters:
    ///   - name: payment method name e.g. (AWXApplePayKey, AWXCardKey)
    ///   - supportedBrands: Card brands to support. Only used for card payments. Defaults to all available brands.
    ///   - session: The payment session containing transaction details.
    ///   - hostViewController: The view controller that will host this element.
    ///     Used for presenting modals like 3DS authentication, redirects, and country selection.
    ///   - delegate: The delegate that receives payment result callbacks.
    /// - Returns: A configured `AWXPaymentElement` ready to be embedded.
    /// - Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
    @objc
    public static func create(
        methodName name: String,
        supportedBrands: [AWXCardBrand]? = AWXCardBrand.allAvailable,
        session: AWXSession,
        hostViewController: UIViewController,
        delegate: AWXPaymentResultDelegate
    ) async throws -> AWXPaymentElement {
        try await create(
            session: session,
            methodProvider: SinglePaymentMethodProvider(
                session: session,
                name: name,
                supportedCardBrands: supportedBrands
            ),
            hostViewController: hostViewController,
            delegate: delegate
        )
    }

    /// Creates an embedded payment element with a specific payment method using a single view controller as both host and delegate.
    ///
    /// This is a convenience method for when your view controller conforms to `AWXPaymentResultDelegate`.
    ///
    /// - Parameters:
    ///   - name: Payment method name (e.g., `AWXApplePayKey`, `AWXCardKey`).
    ///   - supportedBrands: Card brands to support. Only used for card payments. Defaults to all available brands.
    ///   - session: The payment session containing transaction details.
    ///   - delegate: The view controller that will host this element and receive payment result callbacks.
    /// - Returns: A configured `AWXPaymentElement` ready to be embedded.
    /// - Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
    @objc
    public static func create(
        methodName name: String,
        supportedBrands: [AWXCardBrand]? = AWXCardBrand.allAvailable,
        session: AWXSession,
        delegate: UIViewController & AWXPaymentResultDelegate
    ) async throws -> AWXPaymentElement {
        try await create(
            session: session,
            methodProvider: SinglePaymentMethodProvider(
                session: session,
                name: name,
                supportedCardBrands: supportedBrands
            ),
            hostViewController: delegate,
            delegate: delegate
        )
    }

    static func create(
        session: AWXSession,
        methodProvider: PaymentMethodProvider,
        hostViewController: UIViewController,
        delegate: AWXPaymentResultDelegate
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
            delegate: delegate
        )
        
        // Analytics
        AnalyticsLogger.log(
            action: .paymentLaunched,
            extraInfo: [
                .subtype: "embedded",
                .expressCheckout: session.isExpressCheckout
            ]
        )
        
        return element
    }

    init(
        hostViewController: UIViewController,
        methodProvider: PaymentMethodProvider,
        delegate: AWXPaymentResultDelegate
    ) {
        self.hostViewController = hostViewController
        self.methodProvider = methodProvider
        self.delegate = delegate
        super.init()

        // Now set the internal delegate and viewController
        self.paymentUIContext.delegate = delegate
        self.paymentUIContext.viewController = hostViewController

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

    func sections() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()

        if methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }

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
        return sections
    }

    func sectionController(for section: PaymentSectionType) -> AnySectionController<PaymentSectionType, String> {
        switch section {
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
                layout: .accordion,
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
                cardPaymentMethod: methodProvider.method(named: AWXCardKey)!,
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext,
                layout: .accordion,
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
                paymentUIContext: paymentUIContext,
                layout: .accordion,
                imageLoader: imageLoader
            ).anySectionController()
            return controller
        case .accordion(let position):
            return AccordionSectionController(
                position: position,
                methodProvider: methodProvider,
                imageLoader: imageLoader
            ).anySectionController()
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
