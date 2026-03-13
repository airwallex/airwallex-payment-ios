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
import AirwallexPayment
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
/// - Keyboard handling is the host app's responsibility
@MainActor
@objc
public class AWXPaymentElement: NSObject {

    private static let launchType = "embedded_element"

    /// The embeddable view containing the payment UI.
    ///
    /// Add this view to your view hierarchy using Auto Layout constraints.
    /// The view's height will update automatically based on its content.
    @objc public var view: UIView { embeddedView }

    /// The delegate that receives payment lifecycle callbacks.
    @objc public weak var delegate: AWXPaymentElementDelegate?

    // MARK: - Private Properties

    private let methodProvider: PaymentMethodProvider
    let paymentUIContext = PaymentSheetUIContext()
    private lazy var collectionViewManager: CollectionViewManager = {
        let listConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        listConfiguration.interSectionSpacing = 16
        let manager = CollectionViewManager(
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
    ///   - session: The payment session containing transaction details.
    ///   - delegate: The delegate that receives payment lifecycle callbacks.
    ///   - configuration: Configuration options for the payment element.
    /// - Returns: A configured `AWXPaymentElement` ready to be embedded.
    /// - Throws: `AWXUIContext.LaunchError` if session validation fails or payment methods cannot be fetched.
    @objc
    public static func create(
        session: AWXSession,
        delegate: AWXPaymentElementDelegate,
        configuration: Configuration = Configuration()
    ) async throws -> AWXPaymentElement {
        let methodProvider = try makeMethodProvider(session: session, configuration: configuration)

        return try await create(
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
        case .paymentSheet:
            return PaymentSheetMethodProvider(
                session: session,
                isApplePaySelectable: !configuration.showsApplePayAsPrimaryButton
            )
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
        session: AWXSession,
        methodProvider: PaymentMethodProvider,
        delegate: AWXPaymentElementDelegate,
        configuration: Configuration = Configuration()
    ) async throws -> AWXPaymentElement {
        // Validate session
        do {
            try session.validate()
        } catch {
            throw AWXUIContext.LaunchError.invalidSession(underlyingError: error)
        }

        // Risk event
        RiskLogger.log(.transactionInitiated)

        // Analytics
        let extraInfo: [AnalyticEvent.Fields: Any] = if configuration.elementType == .addCard {
            [.launchType: launchType,
             .paymentMethod: AWXCardKey]
        } else {
            [.launchType: launchType,
             .showsApplePayAsPrimaryButton: configuration.showsApplePayAsPrimaryButton,
             .layout: configuration.layout.displayName]
        }
        AnalyticsLogger.bindSession(session: session, extraInfo: extraInfo)
        AnalyticsLogger.log(action: .paymentLaunched)

        // fetch payment methods using method provider
        try await methodProvider.getPaymentMethodTypes()

        // Create element with all dependencies ready
        let element = AWXPaymentElement(
            methodProvider: methodProvider,
            delegate: delegate,
            configuration: configuration
        )

        return element
    }

    init(
        methodProvider: PaymentMethodProvider,
        delegate: AWXPaymentElementDelegate,
        configuration: Configuration = Configuration()
    ) {
        self.methodProvider = methodProvider
        self.delegate = delegate
        self.configuration = configuration
        super.init()

        // Apply theme color from appearance configuration
        AWXTheme.shared().tintColor = configuration.appearance.tintColor

        // Configure payment UI context
        self.paymentUIContext.layout = configuration.layout
        self.paymentUIContext.showsApplePayAsPrimaryButton = configuration.showsApplePayAsPrimaryButton
        self.paymentUIContext.paymentElement = self
        // AWXPaymentElement implements AWXPaymentResultDelegate to bridge to AWXPaymentElementDelegate
        self.paymentUIContext.delegate = self

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

    private var displayMethodTab: Bool {
        // Not needed for `addCard` element
        if configuration.elementType == .addCard {
            return false
        }

        // Not needed for accordion layout
        if configuration.layout == .accordion {
            return false
        }

        // `standard` element: tab layout with a single payment method.
        if methodProvider.methods.count == 1 {
            // Single payment method available
            let methodName = methodProvider.selectedMethod?.name ?? ""
            // hide method tab when only apple pay or add card available
            switch methodName {
            case AWXApplePayKey:
                return !paymentUIContext.showsApplePayAsPrimaryButton
            case AWXCardKey:
                return !methodProvider.consents.isEmpty
            default:
                return true
            }
        } else if methodProvider.methods.count == 0 {
            // never expected, should have thrown an error during creation
            return false
        } else {
            // Display payment method tab when multiple payment methods are available
            return true
        }
    }

    private func sectionsForTabLayout() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()
        if paymentUIContext.showsApplePayAsPrimaryButton && methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }
        if displayMethodTab {
            // horizontal list
            sections.append(.methodList)
        }
        //  display selected payment method
        if let selectedMethodType = methodProvider.selectedMethod {
            if selectedMethodType.name == AWXApplePayKey && !paymentUIContext.showsApplePayAsPrimaryButton {
                // Apple Pay selected from tab list (only when not prioritized)
                sections.append(.applePay)
            } else if selectedMethodType.name == AWXCardKey {
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
    
    private func sectionsForAccordionLayout() -> [PaymentSectionType] {
        var sections = [PaymentSectionType]()

        // When Apple Pay is prioritized, show it at top before accordion sections
        if paymentUIContext.showsApplePayAsPrimaryButton && methodProvider.isApplePayAvailable {
            sections.append(.applePay)
        }

        // Exclude Apple Pay from accordion list when prioritized
        let excludeApplePay = paymentUIContext.showsApplePayAsPrimaryButton
        if !methodProvider.methodsForAccordionPosition(.top, excludeApplePay: excludeApplePay).isEmpty {
            sections.append(.accordion(.top))
        }

        if let selectedMethodType = methodProvider.selectedMethod {
            if selectedMethodType.name == AWXApplePayKey && !excludeApplePay {
                // Apple Pay selected from accordion (only when not prioritized)
                sections.append(.applePay)
            } else if selectedMethodType.name == AWXCardKey {
                if preferConsentPayment && !methodProvider.consents.isEmpty {
                    sections.append(.cardPaymentConsent)
                } else {
                    sections.append(.cardPaymentNew)
                }
            } else if selectedMethodType.hasSchema {
                sections.append(.schemaPayment(selectedMethodType.name))
            }
        }

        if !methodProvider.methodsForAccordionPosition(.bottom, excludeApplePay: excludeApplePay).isEmpty {
            sections.append(.accordion(.bottom))
        }
        return sections
    }
    
    func sections() -> [PaymentSectionType] {

        // For card element type, only show new card payment (no consents, no method list)
        if configuration.elementType == .addCard {
            return [.cardPaymentNew]
        }

        // For Standard element type
        switch configuration.layout {
        case .tab:
            return sectionsForTabLayout()
        case .accordion:
            return sectionsForAccordionLayout()
        }
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

// MARK: - AWXPaymentResultDelegate

extension AWXPaymentElement: @MainActor AWXPaymentResultDelegate {
    public func paymentViewController(
        _ controller: UIViewController?,
        didCompleteWith status: AirwallexPaymentStatus,
        error: Error?
    ) {
        let methodName = paymentUIContext.currentPaymentMethod ?? "unknown"
        collectionViewManager.context.stopLoading()
        notifyProcessingStateChanged(for: methodName, isProcessing: false)
        delegate?.paymentElement(self, didCompleteFor: methodName, with: status, error: error)
    }

    public func paymentViewController(
        _ controller: UIViewController?,
        didCompleteWithPaymentConsentId paymentConsentId: String
    ) {
        let methodName = paymentUIContext.currentPaymentMethod ?? "unknown"
        delegate?.paymentElement?(self, didCompleteFor: methodName, withPaymentConsentId: paymentConsentId)
    }
}

// MARK: - Processing State Notification

extension AWXPaymentElement {
    /// Notifies the delegate about payment processing state changes.
    ///
    /// Call this when payment processing starts or stops. If the delegate implements
    /// `paymentElement(_:onProcessingStateChangedFor:isProcessing:)`, it will be called.
    /// Otherwise, returns `false` so the caller can fall back to default behavior.
    ///
    /// - Parameters:
    ///   - paymentMethod: The name of the payment method being processed.
    ///   - isProcessing: `true` when processing starts, `false` when it ends.
    /// - Returns: `true` if the delegate handled the notification, `false` if fallback is needed.
    @discardableResult
    func notifyProcessingStateChanged(for paymentMethod: String, isProcessing: Bool) -> Bool {
        guard let method = delegate?.paymentElement(_:onProcessingStateChangedFor:isProcessing:) else {
            return false
        }
        method(self, paymentMethod, isProcessing)
        return true
    }

    func notifyValidationFailed(
        for paymentMethod: String,
        invalidInputView: UIView
    ) {
        delegate?.paymentElement?(
            self,
            validationFailedFor: paymentMethod,
            invalidInputView: invalidInputView
        )
    }
}
