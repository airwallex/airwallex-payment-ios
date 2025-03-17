//
//  AWXUIContext+extension.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

//  MARK: - Method List
public extension AWXUIContext {
    private static let subtypeDropin = "dropin"
    private static let subtypeElement = "component"
    enum LaunchStyle {
        case push
        case present
    }
    
    /// Launches the Airwallex payment sheet.
    /// - Parameters:
    ///   - hostingVC: The view controller that launch the payment sheet and also acts as the `AWXPaymentResultDelegate`.
    ///   - session: The current payment session.
    ///   - methodNames: An optional array of payment method names used to filter the payment methods returned by the server.
    ///   - style: The presentation style of the payment sheet. Defaults to `.push`.
    @MainActor func launchPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                  session: AWXSession,
                                  filterBy methodNames: [String]? = nil,
                                  style: LaunchStyle = .push) {
        launchPayment(
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
    @MainActor func launchPayment(from hostingVC: UIViewController,
                                  session: AWXSession,
                                  paymentResultDelegate: AWXPaymentResultDelegate,
                                  filterBy methodNames: [String]? = nil,
                                  style: LaunchStyle = .push) {
        if let methodNames {
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
            style: style
        )
        
        AnalyticsLogger.log(action: .paymentLaunched, extraInfo: [.subtype: Self.subtypeDropin])
    }
}

//  MARK: - Single Payment Method
public extension AWXUIContext {
    
    /// Launches the Airwallex card payment flow.
    /// - Parameters:
    ///   - hostingVC: The view controller that presents the payment sheet and acts as the `AWXPaymentResultDelegate`.
    ///   - session: The active payment session.
    ///   - supportedBrands: A list of supported card brands for the payment session.
    ///   - style: The presentation style of the payment sheet, which defaults to `.push`.
    @MainActor func launchCardPayment(from hostingVC: UIViewController & AWXPaymentResultDelegate,
                                      session: AWXSession,
                                      supportedBrands: [AWXCardBrand],
                                      style: LaunchStyle = .push) {
        launchCardPayment(
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
    @MainActor func launchCardPayment(from hostingVC: UIViewController,
                                      session: AWXSession,
                                      paymentResultDelegate: AWXPaymentResultDelegate,
                                      supportedBrands: [AWXCardBrand],
                                      style: LaunchStyle = .push) {
        assert(!supportedBrands.isEmpty, "supported brands should never be empty")
        launchPayment(
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
    @MainActor func launchPayment(name: String,
                                  from hostingVC: UIViewController,
                                  session: AWXSession,
                                  paymentResultDelegate: AWXPaymentResultDelegate,
                                  supportedBrands: [AWXCardBrand]? = nil,
                                  style: LaunchStyle = .push) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if name == AWXCardKey {
            assert(supportedBrands != nil && supportedBrands?.isEmpty == false, "Supported card brands are required for card payment.")
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
            style: style
        )
        AnalyticsLogger.log(action: .paymentLaunched, extraInfo: [.subtype: Self.subtypeElement, .paymentMethod: name])
    }
}

private extension AWXUIContext {
    
    @MainActor func launchPayment(from hostingVC: UIViewController,
                                  session: AWXSession,
                                  paymentMethodProvider: PaymentMethodProvider,
                                  paymentResultDelegate: AWXPaymentResultDelegate,
                                  style: LaunchStyle) {
        self.session = session
        self.delegate = paymentResultDelegate
        let paymentVC = PaymentMethodsViewController(methodProvider: paymentMethodProvider)
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
