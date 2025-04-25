//
//  PaymentSessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
#if canImport(AirwallexCore)
import AirwallexCore
#endif

public class PaymentSessionHandler: NSObject {
    enum ValidationError: ErrorLoggable {
        case invalidPayment(underlyingError: Error)
        
        // CustomNSError - for objc
        static var errorDomain: String {
            AWXSDKErrorDomain
        }
        
        var errorUserInfo: [String : Any] {
            [NSLocalizedDescriptionKey: errorDescription]
        }
        
        // LocalizedError - for error.localizedDescription
        var errorDescription: String {
            switch self {
            case let .invalidPayment(underlyingError: error):
                return error.localizedDescription
            }
        }
        
        var eventName: String {
            return "session_handler_error"
        }
        
        var eventType: String? {
            return "payment_validation_failure"
        }
    }
    let session: AWXSession
    
    private(set) var actionProvider: AWXDefaultProvider!
    
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
    
    // UI Integration support
    @_spi(AWX) public typealias DismissActionBlock = (@escaping () -> Void) -> Void
    var dismissAction: DismissActionBlock? = nil
    
    @_spi(AWX) public init(session: AWXSession,
                           viewController: UIViewController,
                           paymentResultDelegate: AWXPaymentResultDelegate?,
                           methodType: AWXPaymentMethodType? = nil,
                           dismissAction: DismissActionBlock? = nil) {
        self.session = session
        self._viewController = viewController
        self.methodType = methodType
        self.paymentResultDelegate = paymentResultDelegate
        self.dismissAction = dismissAction
    }
}

/// expose for low-level API integration
@objc public extension PaymentSessionHandler {
    /// Initiates an Apple Pay transaction.
    /// This method sets up and starts the Apple Pay payment flow.
    func startApplePay() {
        do {
            try confirmApplePay(cancelPaymentOnDismiss: true)
        } catch {
            handleFailure(paymentResultDelegate, error)
        }
    }
    
    /// Initiates a card payment transaction.
    /// This method sets up and confirms a card-based payment, including optional billing and card-saving preferences.
    /// - Parameters:
    ///   - card: The card details required for processing the payment.
    ///   - billing: Billing information for the transaction (optional).
    ///   - saveCard: A boolean indicating whether to save the card for future transactions (default is `false`).
    func startCardPayment(with card: AWXCard,
                          billing: AWXPlaceDetails?,
                          saveCard: Bool = false) {
        do {
            try confirmCardPayment(with: card, billing: billing, saveCard: saveCard)
        } catch {
            handleFailure(paymentResultDelegate, error)
        }
    }
    
    /// Initiates a payment using AWXPaymentConsent
    /// This method processes a payment using a previously obtained payment consent, which may require additional input such as a CVC.
    /// - Parameters:
    ///   - consent: The payment consent retrieved from the server, authorizing this transaction.
    ///   If The payment method details, which may require additional input such as a CVC for validation.
    func startConsentPayment(with consent: AWXPaymentConsent) {
        do {
            try confirmConsentPayment(with: consent)
        } catch {
            handleFailure(paymentResultDelegate, error)
        }
    }
    
    /// Initiates a payment using a consent ID.
    /// - Parameter consentId: The previously generated consent identifier.
    func startConsentPayment(withId consentId: String) {
        do {
            try confirmConsentPayment(withId: consentId)
        } catch {
            handleFailure(paymentResultDelegate, error)
        }
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - name: The name of the payment method, as defined by the payment platform.
    ///   - additionalInfo: A dictionary containing any additional data required for processing the payment.
    func startRedirectPayment(with name: String, additionalInfo: [String: String]?) {
        do {
            try confirmRedirectPayment(with: name, additionalInfo: additionalInfo)
        } catch {
            handleFailure(paymentResultDelegate, error)
        }
    }
}

// for internal usage
@_spi(AWX) public extension PaymentSessionHandler {
    /// Initiates an Apple Pay transaction.
    /// - Parameter cancelPaymentOnDismiss: Determines the behavior when the Apple Pay sheet is dismissed.
    ///   - If `true`, the standard Apple Pay flow is followed, and the payment result delegate
    ///     receives a cancellation callback if the user dismisses the sheet.
    ///   - If `false`, dismissing the Apple Pay sheet does not trigger a cancellation callback,
    func confirmApplePay(cancelPaymentOnDismiss: Bool) throws {
        let applePayProvider = AWXApplePayProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        do {
            try applePayProvider.validate()
        } catch {
            let error = ValidationError.invalidPayment(underlyingError: error)
            debugLog("\(error)")
            throw error
        }
        actionProvider = applePayProvider
        if cancelPaymentOnDismiss {
            applePayProvider.startPayment()
        } else {
            applePayProvider.handleFlow()
        }
    }
    
    /// Initiates a card payment transaction.
    /// This method sets up and confirms a card-based payment, including optional billing and card-saving preferences.
    /// - Parameters:
    ///   - card: The card details required for processing the payment.
    ///   - billing: Billing information for the transaction (optional).
    ///   - saveCard: A boolean indicating whether to save the card for future transactions (default is `false`).
    func confirmCardPayment(with card: AWXCard,
                            billing: AWXPlaceDetails?,
                            saveCard: Bool = false) throws {
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        do {
            try cardProvider.validate(card: card, billing: billing)
        } catch {
            let error = ValidationError.invalidPayment(underlyingError: error)
            debugLog("\(error)")
            throw error
        }
        actionProvider = cardProvider
        cardProvider.confirmPaymentIntent(with: card, billing: billing, saveCard: saveCard)
    }
    
    /// Initiates a payment using AWXPaymentConsent
    /// This method processes a payment using a previously obtained payment consent, which may require additional input such as a CVC.
    /// - Parameters:
    ///   - consent: The payment consent retrieved from the server, authorizing this transaction.
    ///   If The payment method details, which may require additional input such as a CVC for validation.
    func confirmConsentPayment(with consent: AWXPaymentConsent) throws {
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        do {
            try cardProvider.validate(consent: consent)
        } catch {
            let error = ValidationError.invalidPayment(underlyingError: error)
            debugLog("\(error)")
            throw error
        }
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
    func confirmConsentPayment(withId consentId: String) throws {
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        do {
            try cardProvider.validate(consentId: consentId)
        } catch {
            let error = ValidationError.invalidPayment(underlyingError: error)
            debugLog("\(error)")
            throw error
        }
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
    func confirmRedirectPayment(with name: String, additionalInfo: [String: String]?) throws {
        let redirectAction = AWXRedirectActionProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        do {
            try redirectAction.validate(name: name)
        } catch {
            let error = ValidationError.invalidPayment(underlyingError: error)
            debugLog("\(error)")
            throw error
        }
        actionProvider = redirectAction
        redirectAction.confirmPaymentIntent(with: name, additionalInfo: additionalInfo)
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - paymentMethod: The payment method details, pre-validated with all required information.
    func confirmRedirectPayment(with paymentMethod: AWXPaymentMethod) throws {
        let redirectAction = AWXRedirectActionProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        do {
            try redirectAction.validate(name: paymentMethod.type)
        } catch {
            let error = ValidationError.invalidPayment(underlyingError: error)
            debugLog("\(error)")
            throw error
        }
        actionProvider = redirectAction
        redirectAction.confirmPaymentIntent(with: paymentMethod, paymentConsent: nil)
    }
    
    private func handleFailure(_ paymentResultDelegate: AWXPaymentResultDelegate?,
                               _ error: Error) {
        paymentResultDelegate?.paymentViewController(nil, didCompleteWith: .failure, error: error)
        guard let error = error as? ErrorLoggable else {
            assert(false, "expected PaymentSessionHandler.ValidationError but get \(error.localizedDescription)")
            return
        }
        AnalyticsLogger.log(error: error)
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
        if let dismissAction {
            if let methodType, methodType.name == AWXApplePayKey, status == .inProgress {
                // Remain in PaymentViewController when the Apple Pay status is .inProgress for UI integration
                // This status typically occurs when the user forcefully dismisses the PKPaymentAuthorizationController—
                // for example, by backgrounding the app—after successfully authorizing the payment.
                return
            }
            dismissAction {
                self.paymentResultDelegate?.paymentViewController(self.viewController, didCompleteWith: status, error: error)
            }
            self.dismissAction = nil
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
