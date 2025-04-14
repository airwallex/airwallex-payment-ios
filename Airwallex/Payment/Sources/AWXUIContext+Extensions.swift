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
#elseif canImport(AirwallexCore)
import AirwallexCore
#endif

//  MARK: - Method List
@objc public extension AWXUIContext {
    private static let subtypeDropin = "dropin"
    private static let subtypeElement = "component"
    @objc enum LaunchStyle: Int {
        case push
        case present
    }
    
    @objc enum PaymentLayout: Int, CaseIterable {
        case accordion
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
    
    enum LaunchError: ErrorLoggable {
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
        // ErrorLoggable
        var eventName: String {
            "ui_launch_error"
        }
        
        var eventType: String? {
            "validation_failure"
        }
    }
        
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
            if let session = session as? AWXOneOffSession,
               !methodNames.contains(where: { $0 == AWXCardKey }) {
                //  avoid requesting consents if AWXCardKey is not included in methodNames
                session.hidePaymentConsents = true
            }
        }
        launchPayment(
            from: hostingVC,
            session: session,
            paymentMethodProvider: PaymentSheetMethodProvider(session: session),
            paymentResultDelegate: paymentResultDelegate,
            launchStyle: launchStyle,
            layout: layout
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
    ///   - launchStyle: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor static func launchCardPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                             session: AWXSession,
                                             supportedBrands: [AWXCardBrand] = AWXCardBrand.all,
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
                                             supportedBrands: [AWXCardBrand] = AWXCardBrand.all,
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
                                         supportedBrands: [AWXCardBrand]? = AWXCardBrand.all,
                                         launchStyle: LaunchStyle = .push) {
        let name = name.trimmed
        
        if name == AWXCardKey {
            guard let supportedBrands,
                  !supportedBrands.isEmpty else {
                handleLaunchFailure(
                    paymentResultDelegate,
                    LaunchError.invalidCardBrand("supportedBrands should not be empty for card payment")
                )
                return
            }
            guard Set(supportedBrands).isSubset(of: AWXCardBrand.all) else {
                handleLaunchFailure(
                    paymentResultDelegate,
                    LaunchError.invalidCardBrand("make sure you only include card brands defined in AWXCardBrand")
                )
                return
            }
        }
        let methodProvider = SinglePaymentMethodProvider(
            session: session,
            name: name,
            supportedCardBrands: supportedBrands
        )
        launchPayment(
            from: hostingVC,
            session: session,
            paymentMethodProvider: methodProvider,
            paymentResultDelegate: paymentResultDelegate,
            launchStyle: launchStyle
        )
        AnalyticsLogger.log(action: .paymentLaunched, extraInfo: [.subtype: Self.subtypeElement, .paymentMethod: name])
    }
}

private extension AWXUIContext {
    
    @MainActor static func launchPayment(from hostingVC: UIViewController,
                                         session: AWXSession,
                                         paymentMethodProvider: PaymentMethodProvider,
                                         paymentResultDelegate: AWXPaymentResultDelegate,
                                         launchStyle: LaunchStyle,
                                         layout: PaymentLayout = .tab) {
        do {
            try session.validate()
        } catch {
            handleLaunchFailure(
                paymentResultDelegate,
                LaunchError.invalidSession(underlyingError: error)
            )
            return
        }
        
        guard let secret = AWXAPIClientConfiguration.shared().clientSecret,
              !secret.isEmpty else {
            handleLaunchFailure(
                paymentResultDelegate,
                LaunchError.invalidClientSecret("please update client secret on AWXAPIClientConfiguration.shared()")
            )
            return
        }
        
        AWXUIContext.shared().session = session
        AWXUIContext.shared().delegate = paymentResultDelegate
        switch launchStyle {
        case .push:
            guard let nav = hostingVC.navigationController else {
                handleLaunchFailure(
                    paymentResultDelegate,
                    LaunchError.invalidViewHierarchy("hosting view controller is not embeded in navigation controller")
                )
                return
            }
            let paymentVC = PaymentViewController(
                methodProvider: paymentMethodProvider,
                layout: layout
            )
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
            let paymentVC = PaymentViewController(
                methodProvider: paymentMethodProvider,
                layout: layout
            )
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
    
    static func handleLaunchFailure(_ paymentResultDelegate: AWXPaymentResultDelegate,
                                    _ error: LaunchError) {
        paymentResultDelegate.paymentViewController(nil, didCompleteWith: .failure, error: error)
        debugLog("\(error)")
        AnalyticsLogger.log(error: error)
    }
}
