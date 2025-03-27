//
//  AWXUIContext+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(Core)
import Core
#endif

//  MARK: - Method List
@objc public extension AWXUIContext {
    private static let subtypeDropin = "dropin"
    private static let subtypeElement = "component"
    @objc enum LaunchStyle: Int {
        case push
        case present
    }
    
    enum LaunchError: CustomNSError, LocalizedError {
        case invalidCardBrand(String)
        case invalidViewHierarchy(String)
        case invalidMethodFilter(String)
        case invalidClientSecret(String)
        case invalidSession(underlyingError: Error)
        
        // CustomNSError - for objc
        public static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        public var errorUserInfo: [String : Any] {
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
    }
        
    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet and also acts as the `AWXPaymentResultDelegate`.
    ///   - session: The current payment session.
    ///   - methodNames: An optional array of payment method names used to filter the payment methods returned by the server.
    ///   - style: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor static func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                         session: AWXSession,
                                         filterBy methodNames: [String]? = nil,
                                         style: LaunchStyle = .push) throws {
        try launchPayment(
            from: hostingVC,
            session: session,
            paymentResultDelegate: hostingVC,
            filterBy: methodNames,
            style: style
        )
    }
    
    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet
    ///   - session: The current payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - methodNames: An optional array of payment method names used to filter the payment methods returned by the server.
    ///   - style: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor static func launchPayment(from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         filterBy methodNames: [String]? = nil,
                                         style: LaunchStyle = .push) throws {
        if let methodNames {
            guard !methodNames.isEmpty else {
                throw LaunchError.invalidMethodFilter("filter should not be empty")
            }
            session.paymentMethods = methodNames
            if let session = session as? AWXOneOffSession,
               !methodNames.contains(where: { $0 == AWXCardKey }) {
                //  avoid requesting consents if AWXCardKey is not included in methodNames
                session.hidePaymentConsents = true
            }
        }
        try launchPayment(
            from: hostingVC,
            session: session,
            paymentMethodProvider: PaymentSheetMethodProvider(session: session),
            paymentResultDelegate: paymentResultDelegate,
            style: style
        )
        
        AnalyticsLogger.log(action: .paymentLaunched, extraInfo: [.subtype: Self.subtypeDropin])
    }
}

//  MARK: - Single Payment Method
@objc public extension AWXUIContext {
    
    /// Launches the Airwallex card payment flow.
    /// - Parameters:
    ///   - hostingVC: The view controller that presents the payment sheet and acts as the `AWXPaymentResultDelegate`.
    ///   - session: The active payment session.
    ///   - supportedBrands: A list of supported card brands for the payment session.
    ///   - style: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor static func launchCardPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                             session: AWXSession,
                                             supportedBrands: [AWXCardBrand] = AWXCardBrand.all,
                                             style: LaunchStyle = .push) throws {
        try launchCardPayment(
            from: hostingVC,
            session: session,
            paymentResultDelegate: hostingVC,
            supportedBrands: supportedBrands,
            style: style
        )
    }
    /// Launches the Airwallex card payment flow.
    /// - Parameters:
    ///   - hostingVC: The view controller that presents the payment sheet
    ///   - supportedBrands: A list of supported card brands for the payment session.
    ///   - session: The active payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - style: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor static func launchCardPayment(from hostingVC: UIViewController,
                                             session: AWXSession,
                                             paymentResultDelegate: AWXPaymentResultDelegate,
                                             supportedBrands: [AWXCardBrand] = AWXCardBrand.all,
                                             style: LaunchStyle = .push) throws {
        try launchPayment(
            name: AWXCardKey,
            from: hostingVC,
            session: session,
            paymentResultDelegate: paymentResultDelegate,
            supportedBrands: supportedBrands,
            style: style
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
    ///   - style: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor static func launchPayment(name: String,
                                         from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         supportedBrands: [AWXCardBrand]? = nil,
                                         style: LaunchStyle = .push) throws {
        let name = name.trimmed
        
        if name == AWXCardKey {
            guard let supportedBrands,
                  !supportedBrands.isEmpty else {
                throw LaunchError.invalidCardBrand("supportedBrands should not be empty for card payment")
            }
            guard Set(supportedBrands).isSubset(of: AWXCardBrand.all) else {
                throw LaunchError.invalidCardBrand("make sure you only include card brands defined in AWXCardBrand")
            }
        }
        let methodProvider = SinglePaymentMethodProvider(
            session: session,
            name: name,
            supportedCardBrands: supportedBrands
        )
        try launchPayment(
            from: hostingVC,
            session: session,
            paymentMethodProvider: methodProvider,
            paymentResultDelegate: paymentResultDelegate,
            style: style
        )
        AnalyticsLogger.log(action: .paymentLaunched, extraInfo: [.subtype: Self.subtypeElement, .paymentMethod: name])
    }
}

private extension AWXUIContext {
    
    @MainActor static func launchPayment(from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentMethodProvider: PaymentMethodProvider,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         style: LaunchStyle) throws {
        do {
            try session.validate()
        } catch {
            throw LaunchError.invalidSession(underlyingError: error)
        }
        
        guard let secret = AWXAPIClientConfiguration.shared().clientSecret,
              !secret.isEmpty else {
            throw LaunchError.invalidClientSecret("please update client secret on AWXAPIClientConfiguration.shared()")
        }
        
        AWXUIContext.shared().session = session
        AWXUIContext.shared().delegate = paymentResultDelegate
        let paymentVC = PaymentMethodsViewController(methodProvider: paymentMethodProvider)
        switch style {
        case .push:
            guard let nav = hostingVC.navigationController else {
                throw LaunchError.invalidViewHierarchy("hossting view controller is not embeded in navigation controller")
            }
            nav.pushViewController(paymentVC, animated: true)
            AWXUIContext.shared().paymentUIDismissAction = { [weak paymentVC, weak nav] completion in
                guard let paymentVC, let nav else {
                    completion?()
                    return
                }
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    completion?()
                }
                guard let index = nav.viewControllers.firstIndex(of: paymentVC),
                      let targetVC = nav.viewControllers[safe: index - 1] else {
                    nav.popViewController(animated: true)
                    CATransaction.commit()
                    return
                }
                nav.popToViewController(targetVC, animated: true)
                CATransaction.commit()
            }
        case .present:
            let nav = UINavigationController(rootViewController: paymentVC)
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
            hostingVC.present(nav, animated: true)
            AWXUIContext.shared().paymentUIDismissAction = { [weak nav] completion in
                guard let nav else {
                    completion?()
                    return
                }
                nav.dismiss(animated: true) {
                    completion?()
                }
            }
        }
    }
}
