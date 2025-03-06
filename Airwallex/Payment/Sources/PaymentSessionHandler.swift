//
//  PaymentSessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public class PaymentSessionHandler: NSObject {
    
    private let session: AWXSession
    
    private var actionProvider: AWXDefaultProvider!
    
    weak var _viewController: UIViewController?
    
    private var viewController: UIViewController {
        assert(_viewController != nil, "The view controller that launches the payment is expected to remain present until the session ends.")
        return _viewController ?? (UIApplication.shared.keyWindow?.rootViewController ?? UIViewController())
    }

    private var paymentResultDelegate: AWXPaymentResultDelegate? {
        (viewController as? AWXPaymentResultDelegate) ?? AWXUIContext.shared().delegate
    }
    
    private var methodType: AWXPaymentMethodType?
    
    /// Initializes a `PaymentSessionHandler` with a payment session and the view controller from which the payment is initiated.
    /// - Parameters:
    ///   - session: The payment session containing relevant transaction details.
    ///   - viewController: The view controller that initiates the payment process.
    ///   - methodType: The payment method type returned from the server (optional).
    public init(session: AWXSession,
                viewController: UIViewController,
                methodType: AWXPaymentMethodType? = nil) {
        self.session = session
        self._viewController = viewController
        self.methodType = methodType
    }
    
    /// Initializes a `PaymentSessionHandler` with a payment session and a view controller that also acts as a payment result delegate.
    /// - Parameters:
    ///   - session: The payment session containing relevant transaction details.
    ///   - viewController: The view controller initiating the payment, which conforms to `AWXPaymentResultDelegate` for handling payment outcomes.
    ///   - methodType: The payment method type returned from the server (optional).
    public init(session: AWXSession,
                viewController: UIViewController & AWXPaymentResultDelegate,
                methodType: AWXPaymentMethodType? = nil) {
        self.session = session
        self._viewController = viewController
        self.methodType = methodType
    }
    
    /// Initiates an Apple Pay transaction.
    /// This method sets up and starts the Apple Pay payment flow.
    public func startApplePay() {
        assert(methodType == nil || methodType?.name == AWXApplePayKey)
        let applePayProvider = AWXApplePayProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = applePayProvider
        applePayProvider.startPayment()
    }
    
    /// Initiates a card payment transaction.
    /// This method sets up and confirms a card-based payment, including optional billing and card-saving preferences.
    /// - Parameters:
    ///   - card: The card details required for processing the payment.
    ///   - billing: Billing information for the transaction (optional).
    ///   - saveCard: A boolean indicating whether to save the card for future transactions (default is `false`).
    public func startCardPayment(with card: AWXCard,
                                 billing: AWXPlaceDetails?,
                                 saveCard: Bool = false) {
        assert(methodType == nil || methodType?.name == AWXCardKey)
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = cardProvider
        cardProvider.confirmPaymentIntent(with: card, billing: billing, saveCard: saveCard)
    }
    
    /// Initiates a consent-based payment.
    /// This method processes a payment using a previously obtained payment consent, which may require additional input such as a CVC.
    /// - Parameters:
    ///   - consent: The payment consent retrieved from the server, authorizing this transaction.
    ///   - paymentMethod: The payment method details, which may require additional input such as a CVC for validation.
    public func startConsentPayment(with consent: AWXPaymentConsent, paymentMethod: AWXPaymentMethod) {
        assert(methodType == nil || methodType?.name == AWXCardKey)
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = cardProvider
        cardProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: consent)
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - paymentMethod: The payment method details, pre-validated with all required information.
    func startSchemaPayment(with paymentMethod: AWXPaymentMethod) {
        assert(methodType == nil || methodType?.name == paymentMethod.type)
        let schemaProvider = AWXSchemaProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = schemaProvider
        schemaProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: nil)
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - name: The name of the payment method, as defined by the payment platform.
    ///   - additionalInfo: A dictionary containing any additional data required for processing the payment.
    public func startSchemaPayment(with name: String, additionalInfo: [String: String]?) {
        assert(methodType == nil || methodType?.name == name)
        let redirectAction = AWXRedirectActionProvider(
            delegate: self,
            session: session
        )
        actionProvider = redirectAction
        redirectAction.confirmPaymentIntent(with: name, additionalInfo: additionalInfo)
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
        debugLog("stauts: \(status), error: \(error?.localizedDescription ?? "")")
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
