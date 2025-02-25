//
//  AWXUIContext+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

public extension AWXUIContext {
    enum LaunchStyle {
        case push
        case present
    }
    
    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet and also acts as the `AWXPaymentResultDelegate`.
    ///   - session: The current payment session.
    ///   - style: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                  session: AWXSession,
                                  style: LaunchStyle = .push) {
        launchPayment(
            from: hostingVC,
            session: session,
            paymentResultDelegate: hostingVC,
            style: style
        )
    }
    
    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet
    ///   - session: The current payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - style: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor func launchPayment(from hostingVC: UIViewController,
                                  session: AWXSession,
                                  paymentResultDelegate: AWXPaymentResultDelegate,
                                  style: LaunchStyle = .push) {
        let fetcher = AWXPaymentMethodListViewModel(
            session: session,
            apiClient: AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
        )
        launchPayment(
            from: hostingVC,
            session: session,
            paymentMethodFetcher: fetcher,
            paymentResultDelegate: paymentResultDelegate,
            style: style
        )
    }
    
    /// Launches the Airwallex card payment flow.
    /// - Parameters:
    ///   - hostingVC: The view controller that presents the payment sheet and acts as the `AWXPaymentResultDelegate`.
    ///   - supportedBrands: A list of supported card brands for the payment session.
    ///   - session: The active payment session.
    ///   - style: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor func launchCardPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                      supportedBrands: [AWXCardBrand],
                                      session: AWXSession,
                                      style: LaunchStyle = .push) {
        launchCardPayment(
            from: hostingVC,
            session: session,
            supportedBrands: supportedBrands,
            paymentResultDelegate: hostingVC,
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
    @MainActor func launchCardPayment(from hostingVC: UIViewController,
                                      session: AWXSession,
                                      supportedBrands: [AWXCardBrand],
                                      paymentResultDelegate: AWXPaymentResultDelegate,
                                      style: LaunchStyle = .push) {
        assert(!supportedBrands.isEmpty, "supported schemes should never be empty")
        let method = AWXPaymentMethodType()
        method.name = AWXCardKey
        method.displayName = NSLocalizedString("Card", bundle: .payment, comment: "")
        method.cardSchemes = supportedBrands.map {
            let scheme = AWXCardScheme()
            scheme.name = $0.rawValue
            return scheme
        }
        method.transactionMode = session.transactionMode()
        launchPayment(
            methodType: method,
            from: hostingVC,
            session: session,
            paymentResultDelegate: paymentResultDelegate,
            style: style
        )
    }
    
    /// Launches the Airwallex payment flow for a specific payment method.
    /// - Parameters:
    ///   - methodType: The payment method type to be used for the transaction.
    ///   - hostingVC: The view controller that presents the payment sheet.
    ///   - session: The active payment session.
    ///   - paymentResultDelegate: The delegate responsible for handling the payment result.
    ///   - style: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor func launchPayment(methodType: AWXPaymentMethodType,
                                  from hostingVC: UIViewController,
                                  session: AWXSession,
                                  paymentResultDelegate: AWXPaymentResultDelegate,
                                  style: LaunchStyle = .push) {
        assert(session.transactionMode() == methodType.transactionMode, "invalid method type, transaction mode not matched with active session")
        let fetcher = PresetPaymentMethodProvider(
            session: session,
            paymentMethods: [
                methodType
            ]
        )
        launchPayment(
            from: hostingVC,
            session: session,
            paymentMethodFetcher: fetcher,
            paymentResultDelegate: paymentResultDelegate,
            style: style
        )
    }
    
    @MainActor
    internal func launchPayment(from hostingVC: UIViewController,
                                session: AWXSession,
                                paymentMethodFetcher: PaymentMethodFetcher,
                                paymentResultDelegate: AWXPaymentResultDelegate,
                                style: LaunchStyle) {
        self.session = session
        self.delegate = paymentResultDelegate
        let provider = PaymentMethodProvider(provider: paymentMethodFetcher)
        let paymentVC = PaymentMethodsViewController(methodProvider: provider)
        switch style {
        case .push:
            guard let nav = hostingVC.navigationController else {
                assert(false, "unable to push payment sheet from a hostingVC not embeded in navigation stack")
                fallthrough
            }
            nav.pushViewController(paymentVC, animated: true)
            AWXUIContext.shared().paymentUIDismissAction = { [weak hostingVC, weak nav] completion in
                guard let hostingVC, let nav else {
                    completion?()
                    return
                }
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    completion?()
                }
                nav.popToViewController(hostingVC, animated: true)
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
