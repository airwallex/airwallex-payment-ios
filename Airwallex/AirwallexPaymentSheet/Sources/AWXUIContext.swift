//
//  AWXUIContext.swift
//  AirwallexPaymentSheet
//
//  Created by Weiping Li on 2025/4/17.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import UIKit
#if canImport(AirwallexPayment)
import AirwallexCore
import AirwallexPayment
#endif

/// The main UI context for Airwallex payment flows.
///
/// `AWXUIContext` provides a high-level interface for launching pre-built payment flows.
/// It handles the presentation of payment forms, user interactions, and payment processing
/// with minimal integration effort.
///
/// ## Usage
/// ```swift
/// let context = AWXUIContext()
/// context.launchPayment(
///     from: viewController,
///     session: session
/// )
/// ```
@MainActor
@objc public class AWXUIContext: NSObject {
    private static let launchType = "hpp"
    @objc public enum LaunchStyle: Int {
        case push
        case present
    }

    /// Defines the layout style for payment method selection.
    @objc public enum PaymentLayout: Int, CaseIterable {
        /// Display payment methods in an expandable accordion layout.
        case accordion
        /// Display payment methods in a tabbed layout.
        case tab

        public var displayName: String {
            switch self {
            case .accordion:
                "accordion"
            case .tab:
                "tab"
            }
        }
    }

    public enum LaunchError: ErrorLoggable {
        case invalidCardBrand(String)
        case invalidViewHierarchy(String)
        case invalidMethodFilter(String)
        case invalidClientSecret(String)
        case invalidSession(underlyingError: Error)

        // CustomNSError - for objc
        public static var errorDomain: String {
            AWXSDKErrorDomain
        }

        public var errorUserInfo: [String: Any] {
            [NSLocalizedDescriptionKey: errorDescription]
        }

        // LocalizedError - for error.localizedDescription
        var errorDescription: String {
            switch self {
            case .invalidCardBrand(let message):
                return "Invalid card brand: \(message)"
            case .invalidViewHierarchy(let message):
                return "Invalid view hierarchy: \(message)"
            case .invalidMethodFilter(let message):
                return "Invalid method filter: \(message)"
            case .invalidSession(underlyingError: let error):
                return "Invalid session: \(error.localizedDescription)"
            case .invalidClientSecret(let message):
                return "Client secret required: \(message)"
            }
        }
        // ErrorLoggable
        public var eventName: String {
            "ui_launch_error"
        }

        public var eventType: String? {
            "payment_validation_failure"
        }
    }

    @objc public static let shared = AWXUIContext()
    private override init() {}
}

@objc public extension AWXUIContext {
    // MARK: - Launch Payment Sheet

    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet and also acts as the `AWXPaymentResultDelegate`.
    ///   - session: The current payment session.
    ///   - methodNames: An optional array of payment method names used to filter the payment methods returned by the server.
    ///   - launchStyle: The presentation style of the payment sheet. Defaults to `.push`.
    ///   - layout: layout of payment sheet
    @MainActor static func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                         session: AWXSession,
                                         filterBy methodNames: [String]? = nil,
                                         launchStyle: LaunchStyle = .push,
                                         layout: PaymentLayout = .tab) {
        launchPayment(
            from: hostingVC,
            session: session,
            paymentResultDelegate: hostingVC,
            filterBy: methodNames,
            launchStyle: launchStyle,
            layout: layout
        )
    }

    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet
    ///   - session: The current payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - methodNames: An optional array of payment method names used to filter the payment methods returned by the server.
    ///   - launchStyle: The presentation style of the payment sheet. Defaults to `.push`.
    ///   - layout: layout of payment sheet
    @MainActor static func launchPayment(from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         filterBy methodNames: [String]? = nil,
                                         launchStyle: LaunchStyle = .push,
                                         layout: PaymentLayout = .tab) {
        if let methodNames {
            guard !methodNames.isEmpty else {
                handleLaunchFailure(
                    paymentResultDelegate,
                    LaunchError.invalidMethodFilter("filter should not be empty")
                )
                return
            }
            session.paymentMethods = methodNames
        }

        let configuration = Configuration()
        configuration.launchStyle = launchStyle
        configuration.layout = layout

        performLaunch(
            from: hostingVC,
            session: session,
            paymentResultDelegate: paymentResultDelegate,
            configuration: configuration
        )
    }

    // MARK: - Launch by Payment Method

    /// Launches the Airwallex card payment flow.
    /// - Parameters:
    ///   - hostingVC: The view controller that presents the payment sheet and acts as the `AWXPaymentResultDelegate`.
    ///   - session: The active payment session.
    ///   - supportedBrands: A list of supported card brands for the payment session.
    ///   - launchStyle: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor static func launchCardPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                             session: AWXSession,
                                             supportedBrands: [AWXCardBrand] = AWXCardBrand.allAvailable,
                                             launchStyle: LaunchStyle = .push) {
        launchCardPayment(
            from: hostingVC,
            session: session,
            paymentResultDelegate: hostingVC,
            supportedBrands: supportedBrands,
            launchStyle: launchStyle
        )
    }
    /// Launches the Airwallex card payment flow.
    /// - Parameters:
    ///   - hostingVC: The view controller that presents the payment sheet
    ///   - supportedBrands: A list of supported card brands for the payment session.
    ///   - session: The active payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - launchStyle: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor static func launchCardPayment(from hostingVC: UIViewController,
                                             session: AWXSession,
                                             paymentResultDelegate: AWXPaymentResultDelegate,
                                             supportedBrands: [AWXCardBrand] = AWXCardBrand.allAvailable,
                                             launchStyle: LaunchStyle = .push) {
        launchPayment(
            name: AWXCardKey,
            from: hostingVC,
            session: session,
            paymentResultDelegate: paymentResultDelegate,
            supportedBrands: supportedBrands,
            launchStyle: launchStyle
        )
    }

    /// Launches the Airwallex payment sheet for a specified payment method.
    /// - Parameters:
    ///   - name: The name of the payment method.
    ///   API reference: https://www.airwallex.com/docs/api#/Payment_Acceptance/Config/_api_v1_pa_config_payment_method_types/get JSON Object field: items.name
    ///   - hostingVC: The view controller that presents the payment sheet.
    ///   - session: The current payment session containing transaction details.
    ///   - paymentResultDelegate: The delegate that handles payment result callbacks.
    ///   - supportedBrands: A list of supported card brands for the payment method. Required for Card Payment
    ///   - launchStyle: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor static func launchPayment(name: String,
                                         from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         supportedBrands: [AWXCardBrand]? = AWXCardBrand.allAvailable,
                                         launchStyle: LaunchStyle = .push) {
        let configuration = Configuration()
        if name == AWXCardKey {
            configuration.elementType = .addCard
        } else {
            configuration.elementType = .component
            configuration.paymentMethodName = name
        }
        if let supportedBrands {
            configuration.supportedCardBrands = supportedBrands
        }
        configuration.launchStyle = launchStyle

        performLaunch(
            from: hostingVC,
            session: session,
            paymentResultDelegate: paymentResultDelegate,
            configuration: configuration
        )
    }
}

@objc public extension AWXUIContext {

    // MARK: - Launch with Configuration

    /// Launches the Airwallex payment UI using a configuration object.
    /// - Parameters:
    ///   - hostingVC: The view controller that launches the payment UI and also acts as the `AWXPaymentResultDelegate`.
    ///   - session: The current payment session.
    ///   - configuration: Configuration for the payment flow. Defaults to a new `Configuration` instance.
    @MainActor static func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                         session: AWXSession,
                                         configuration: Configuration = Configuration()) {
        performLaunch(
            from: hostingVC,
            session: session,
            paymentResultDelegate: hostingVC,
            configuration: configuration
        )
    }

    /// Launches the Airwallex payment UI using a configuration object.
    /// - Parameters:
    ///   - hostingVC: The view controller that launches the payment UI.
    ///   - session: The current payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - configuration: Configuration for the payment flow. Defaults to a new `Configuration` instance.
    @MainActor static func launchPayment(from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         configuration: Configuration = Configuration()) {
        performLaunch(
            from: hostingVC,
            session: session,
            paymentResultDelegate: paymentResultDelegate,
            configuration: configuration
        )
    }
}

// MARK: - Private

private extension AWXUIContext {
    
    static func performLaunch(from hostingVC: UIViewController,
                              session: AWXSession,
                              paymentResultDelegate: AWXPaymentResultDelegate,
                              configuration: Configuration) {
        let elementType = resolvedElementType(for: configuration)
        
        logLaunchAnalytics(
            session: session,
            configuration: configuration,
            elementType: elementType
        )

        do {
            let methodProvider = try makeMethodProvider(
                session: session,
                configuration: configuration,
                elementType: elementType
            )
            try validateSession(session)
            RiskLogger.log(.transactionInitiated)
            try presentPaymentUI(
                from: hostingVC,
                methodProvider: methodProvider,
                paymentResultDelegate: paymentResultDelegate,
                configuration: configuration
            )
        } catch let error as LaunchError {
            handleLaunchFailure(paymentResultDelegate, error)
        } catch {
            handleLaunchFailure(paymentResultDelegate, .invalidSession(underlyingError: error))
        }
    }
    static func resolvedElementType(for configuration: Configuration) -> ElementType {
        switch configuration.elementType {
        case .paymentSheet, .addCard:
            return configuration.elementType
        case .component:
            guard let name = configuration.paymentMethodName?.trimmed,
                  !name.isEmpty else {
                return .paymentSheet
            }
            return .component
        }
    }

    static func makeMethodProvider(session: AWXSession,
                                   configuration: Configuration,
                                   elementType: ElementType) throws -> PaymentMethodProvider {
        switch elementType {
        case .paymentSheet:
            return PaymentSheetMethodProvider(session: session)
        case .addCard:
            try validateCardBrands(configuration.supportedCardBrands)
            return SinglePaymentMethodProvider(
                session: session,
                name: AWXCardKey,
                supportedCardBrands: configuration.supportedCardBrands
            )
        case .component:
            let name = configuration.paymentMethodName!.trimmed
            if name == AWXCardKey {
                try validateCardBrands(configuration.supportedCardBrands)
            }
            return SinglePaymentMethodProvider(
                session: session,
                name: name,
                supportedCardBrands: configuration.supportedCardBrands
            )
        }
    }

    static func validateCardBrands(_ brands: [AWXCardBrand]) throws {
        guard !brands.isEmpty else {
            throw LaunchError.invalidCardBrand("supportedBrands should not be empty for card payment")
        }
        guard Set(brands).isSubset(of: AWXCardBrand.allAvailable) else {
            throw LaunchError.invalidCardBrand("make sure you only include card brands defined in AWXCardBrand")
        }
    }

    static func validateSession(_ session: AWXSession) throws {
        do {
            try session.validate()
        } catch {
            throw LaunchError.invalidSession(underlyingError: error)
        }

        if session is Session {
            // client secret will be updated on `AWXAPIClientConfiguration.shared()`
            // when `session.ensurePaymentIntent()` called
        } else {
            guard let secret = AWXAPIClientConfiguration.shared().clientSecret,
                  !secret.isEmpty else {
                throw LaunchError.invalidClientSecret("please update client secret on AWXAPIClientConfiguration.shared()")
            }
        }
    }

    @MainActor static func presentPaymentUI(from hostingVC: UIViewController,
                                            methodProvider: PaymentMethodProvider,
                                            paymentResultDelegate: AWXPaymentResultDelegate,
                                            configuration: Configuration) throws {
        let paymentUIContext = PaymentSheetUIContext(delegate: paymentResultDelegate)
        paymentUIContext.layout = configuration.layout
        paymentUIContext.applePayButtonConfiguration = configuration.applePayButton
        paymentUIContext.checkoutButtonConfiguration = configuration.checkoutButton

        switch configuration.launchStyle {
        case .push:
            guard let nav = hostingVC.navigationController else {
                throw LaunchError.invalidViewHierarchy("hosting view controller is not embeded in navigation controller")
            }
            let paymentVC = PaymentViewController(
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            paymentUIContext.dismissAction = { [weak paymentVC, weak nav] completion in
                guard let paymentVC, let nav else {
                    completion()
                    return
                }
                defer {
                    if let coordinator = paymentVC.transitionCoordinator {
                        coordinator.animate(alongsideTransition: nil) { _ in completion() }
                    } else {
                        completion()
                    }
                }
                guard let index = nav.viewControllers.firstIndex(of: paymentVC),
                      let targetVC = nav.viewControllers[safe: index - 1] else {
                    nav.popViewController(animated: true)
                    return
                }
                nav.popToViewController(targetVC, animated: true)
            }
            nav.pushViewController(paymentVC, animated: true)
        case .present:
            let paymentVC = PaymentViewController(
                methodProvider: methodProvider,
                paymentUIContext: paymentUIContext
            )
            let nav = UINavigationController(rootViewController: paymentVC)
            if #unavailable(iOS 26) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithDefaultBackground()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial) // Apply blur
                appearance.shadowColor = UIColor.awxColor(.borderDecorative)

                nav.navigationBar.standardAppearance = appearance
                nav.navigationBar.scrollEdgeAppearance = appearance
                nav.navigationBar.compactAppearance = appearance
                nav.navigationBar.tintColor = UIColor.awxColor(.iconLink)
                if #available(iOS 15.0, *) {
                    nav.navigationBar.compactScrollEdgeAppearance = appearance
                }
            }
            paymentUIContext.dismissAction = { [weak nav] completion in
                guard let nav else {
                    completion()
                    return
                }
                nav.dismiss(animated: true) {
                    completion()
                }
            }
            hostingVC.present(nav, animated: true)
        }
    }

    static func logLaunchAnalytics(session: AWXSession,
                                   configuration: Configuration,
                                   elementType: ElementType) {
        switch elementType {
        case .paymentSheet:
            AnalyticsLogger.bindSession(
                session: session,
                extraInfo: [
                    .launchType: Self.launchType,
                    .layout: configuration.layout.displayName
                ]
            )
            AnalyticsLogger.log(action: .paymentLaunched)
        case .addCard, .component:
            let name: String = if elementType == .addCard {
                AWXCardKey
            } else {
                configuration.paymentMethodName?.trimmed ?? "unknown"
            }
            assert(name != "unknown", "configuration.paymentMethodName is required")
            AnalyticsLogger.bindSession(
                session: session,
                extraInfo: [
                    .launchType: Self.launchType,
                ]
            )
            AnalyticsLogger.log(
                action: .paymentLaunched,
                extraInfo: [
                    .paymentMethod: name
                ]
            )
        }
    }

    static func handleLaunchFailure(_ paymentResultDelegate: AWXPaymentResultDelegate,
                                    _ error: LaunchError) {
        paymentResultDelegate.paymentViewController(nil, didCompleteWith: .failure, error: error)
        debugLog("\(error)")
        AnalyticsLogger.log(error: error)
    }
}
