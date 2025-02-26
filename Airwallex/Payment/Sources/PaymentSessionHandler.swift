//
//  PaymentSessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(Core)
import Core
#endif
#if canImport(ApplePay)
import ApplePay
#endif
#if canImport(Redirect)
import Redirect
#endif
#if canImport(Card)
import Card
#endif

public class PaymentSessionHandler: NSObject {
    
    public struct ValidationFailure:  LocalizedError {
        public var failureReason: String
        init(_ reason: String) {
            self.failureReason = reason
        }
        public var errorDescription: String? {
            failureReason
        }
    }
    
    let session: AWXSession
    
    private var actionProvider: AWXDefaultProvider!
    
    private weak var _viewController: UIViewController?
    
    var viewController: UIViewController {
        assert(_viewController != nil, "The view controller that launches the payment is expected to remain present until the session ends.")
        if let viewController = _viewController {
            return viewController
        }
        let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene
        if #available(iOS 15.0, *) {
            return windowScene?.keyWindow?.rootViewController ?? UIViewController()
        } else {
            return windowScene?.windows.first?.rootViewController ?? UIViewController()
        }
    }

    private(set) var methodType: AWXPaymentMethodType?
    
    private(set) weak var paymentResultDelegate: AWXPaymentResultDelegate?
    
    /// Initializes a `PaymentSessionHandler` with a payment session and the view controller from which the payment is initiated.
    /// - Parameters:
    ///   - session: The payment session containing relevant transaction details.
    ///   - viewController: The view controller that initiates the payment process.
    ///   - paymentResultDelegate: delegate which conforms to `AWXPaymentResultDelegate` for handling payment results
    ///   - methodType: The payment method type returned from the server (optional).
    @objc public init(session: AWXSession,
                      viewController: UIViewController,
                      paymentResultDelegate: AWXPaymentResultDelegate?,
                      methodType: AWXPaymentMethodType? = nil) {
        self.session = session
        self._viewController = viewController
        self.methodType = methodType
        self.paymentResultDelegate = paymentResultDelegate
    }
    
    /// Initializes a `PaymentSessionHandler` with a payment session and a view controller that also acts as a payment result delegate.
    /// - Parameters:
    ///   - session: The payment session containing relevant transaction details.
    ///   - viewController: The view controller initiating the payment, which conforms to `AWXPaymentResultDelegate` for handling payment results.
    ///   - methodType: The payment method type returned from the server (optional).
    @objc public convenience init(session: AWXSession,
                                  viewController: UIViewController & AWXPaymentResultDelegate,
                                  methodType: AWXPaymentMethodType? = nil) {
        self.init(
            session: session,
            viewController: viewController,
            paymentResultDelegate: viewController,
            methodType: methodType
        )
    }
}

/// expose for low-level API integration
@objc public extension PaymentSessionHandler {
    /// Initiates an Apple Pay transaction.
    /// This method sets up and starts the Apple Pay payment flow.
    func startApplePay() throws {
        try startApplePay(cancelPaymentOnDismiss: true)
    }
    
    /// Initiates a card payment transaction.
    /// This method sets up and confirms a card-based payment, including optional billing and card-saving preferences.
    /// - Parameters:
    ///   - card: The card details required for processing the payment.
    ///   - billing: Billing information for the transaction (optional).
    ///   - saveCard: A boolean indicating whether to save the card for future transactions (default is `false`).
    func startCardPayment(with card: AWXCard,
                          billing: AWXPlaceDetails?,
                          saveCard: Bool = false) throws {
        guard (methodType == nil || methodType?.name == AWXCardKey) else {
            throw ValidationFailure("method type not matched")
        }
        
        if let methodType {
            guard !methodType.cardSchemes.isEmpty else {
                throw ValidationFailure("card schemes should not be empty")
            }
        }
        
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = cardProvider
        cardProvider.confirmPaymentIntent(with: card, billing: billing, saveCard: saveCard)
    }
    
    /// Initiates a payment using AWXpaymentConsent
    /// This method processes a payment using a previously obtained payment consent, which may require additional input such as a CVC.
    /// - Parameters:
    ///   - consent: The payment consent retrieved from the server, authorizing this transaction.
    ///   If The payment method details, which may require additional input such as a CVC for validation.
    func startConsentPayment(with consent: AWXPaymentConsent) throws {
        guard !consent.id.isEmpty, consent.id.hasPrefix("cst_") else {
            throw ValidationFailure("invalid consentId")
        }
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = cardProvider
        if let method = consent.paymentMethod,
           let card = method.card,
           card.numberType == AWXCard.NumberType.PAN,
           (card.cvc ?? "").isEmpty == false {
            cardProvider.confirmPaymentIntent(with: method, paymentConsent: consent)
        } else {
            // legacy implementation
            cardProvider.confirmPaymentIntent(with: consent)
        }
    }
    
    /// Initiates a payment using a consent ID.
    /// - Parameter consentId: The previously generated consent identifier.
    func startConsentPayment(withId consentId: String) throws {
        guard !consentId.isEmpty, consentId.hasPrefix("cst_") else {
            throw ValidationFailure("invalid consentId")
        }
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = cardProvider
        // legacy implementation
        cardProvider.confirmPaymentIntent(withPaymentConsentId: consentId)
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - name: The name of the payment method, as defined by the payment platform.
    ///   - additionalInfo: A dictionary containing any additional data required for processing the payment.
    func startRedirectPayment(with name: String, additionalInfo: [String: String]?) throws {
        guard (methodType == nil || methodType?.name == name) else {
            throw ValidationFailure("method type not matched")
        }
        let redirectAction = AWXRedirectActionProvider(
            delegate: self,
            session: session
        )
        actionProvider = redirectAction
        redirectAction.confirmPaymentIntent(with: name, additionalInfo: additionalInfo)
    }
}

extension PaymentSessionHandler {
    /// Initiates an Apple Pay transaction.
    /// - Parameter cancelPaymentOnDismiss: Determines the behavior when the Apple Pay sheet is dismissed.
    ///   - If `true`, the standard Apple Pay flow is followed, and the payment result delegate
    ///     receives a cancellation callback if the user dismisses the sheet.
    ///   - If `false`, dismissing the Apple Pay sheet does not trigger a cancellation callback,
    func startApplePay(cancelPaymentOnDismiss: Bool) throws {
        guard (methodType == nil || methodType?.name == AWXApplePayKey) else {
            throw ValidationFailure("method type not matched")
        }
        do {
            try AWXApplePayProvider.canHandle(session)
        } catch {
            throw ValidationFailure(error.localizedDescription)
        }
        
        let applePayProvider = AWXApplePayProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = applePayProvider
        if cancelPaymentOnDismiss {
            applePayProvider.startPayment()
        } else {
            applePayProvider.handleFlow()
        }
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - paymentMethod: The payment method details, pre-validated with all required information.
    func startRedirectPayment(with paymentMethod: AWXPaymentMethod) throws {
        guard (methodType == nil || methodType?.name == paymentMethod.type) else {
            throw ValidationFailure("method type not matched")
        }
        let schemaProvider = AWXSchemaProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = schemaProvider
        schemaProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: nil)
    }
}

extension PaymentSessionHandler: AWXProviderDelegate {
    public func providerDidStartRequest(_ provider: AWXDefaultProvider) {
        debugLog("start loading")
        viewController.startLoading()
    }
    
    public func providerDidEndRequest(_ provider: AWXDefaultProvider) {
        debugLog("stop loading")
        viewController.stopLoading()
    }
    
    public func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        debugLog("paymentIntentId: \(paymentIntentId)")
        session.updateInitialPaymentIntentId(paymentIntentId)
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWithPaymentConsentId paymentConsentId: String) {
        debugLog("paymentConsentId: \(paymentConsentId)")
        paymentResultDelegate?.paymentViewController?(viewController, didCompleteWithPaymentConsentId: paymentConsentId)
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        if status == .cancel {
            // only log payment_canceled here
            // payment_success and error eent are logged in AWXDefaultProvider
            AnalyticsLogger.log(action: .paymentCanceled)
        }
        debugLog("stauts: \(status), error: \(error?.localizedDescription ?? "N/A")")
        if let action = AWXUIContext.shared().paymentUIDismissAction {
            action {
                self.paymentResultDelegate?.paymentViewController(self.viewController, didCompleteWith: status, error: error)
            }
            AWXUIContext.shared().paymentUIDismissAction = nil
        } else {
            paymentResultDelegate?.paymentViewController(viewController, didCompleteWith: status, error: error)
        }
    }
    
    public func hostViewController() -> UIViewController {
        return viewController
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction) {
        guard let actionProviderClass = ClassToHandleNextActionForType(nextAction) as? AWXDefaultActionProvider.Type else {
            let error = NSError(
                domain: AWXSDKErrorDomain,
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("No provider matched the next action.", bundle: .payment, comment: "")
                ]
            )
            paymentResultDelegate?.paymentViewController(viewController, didCompleteWith: .failure, error: error)
            return
        }
        let actionHandler = actionProviderClass.init(delegate: self, session: session)
        actionHandler.handle(nextAction)
        actionProvider = actionHandler
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldInsert controller: UIViewController) {
        viewController.addChild(controller)
        controller.view.frame = viewController.view.frame.insetBy(dx: 0, dy: viewController.view.frame.maxY)
        viewController.view.addSubview(controller.view)
        controller.didMove(toParent: viewController)
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldPresent controller: UIViewController?, forceToDismiss: Bool, withAnimation: Bool) {
        guard let controller else {
            if forceToDismiss {
                viewController.presentedViewController?.dismiss(animated: withAnimation)
            }
            return
        }
        if forceToDismiss {
            viewController.presentedViewController?.dismiss(animated: withAnimation) {
                self.viewController.present(controller, animated: withAnimation)
            }
        } else {
            viewController.present(controller, animated: withAnimation)
        }
    }
}
