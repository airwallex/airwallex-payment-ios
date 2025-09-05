//
//  PaymentSessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import UIKit

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
    
    private(set) var actionProvider: AWXDefaultProvider?
    
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
    @objc public convenience init(session: AWXSession,
                                  viewController: UIViewController,
                                  paymentResultDelegate: AWXPaymentResultDelegate?,
                                  methodType: AWXPaymentMethodType? = nil) {
        self.init(
            session: session,
            viewController: viewController,
            paymentResultDelegate: paymentResultDelegate,
            methodType: methodType,
            dismissAction: nil
        )
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
    
    lazy var providerFactory: ProviderFactoryProtocol = ProviderFactory()
    
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
        
        // update logger.session here for low-level API integration
        AnalyticsLogger.shared().session = session
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
    /// - Parameter requiresCVC: Whether prompt for user iput for cvc. You typically pass true when the number type of the consent is "PAN"
    func startConsentPayment(withId consentId: String, requiresCVC: Bool = false) {
        do {
            try confirmConsentPayment(withId: consentId, requiresCVC: requiresCVC)
        } catch {
            handleFailure(paymentResultDelegate, error)
        }
    }
    
    /// Initiates a payment with a tokenized consent
    /// - Parameter consentId: The previously generated consent identifier.
    func startConsentPayment(withId consentId: String) {
        startConsentPayment(withId: consentId, requiresCVC: false)
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
    
    class func canHandle(methodType: AWXPaymentMethodType, session: AWXSession) -> Bool {
        guard session.transactionMode() == methodType.transactionMode,
              !methodType.displayName.isEmpty,
              !methodType.name.isEmpty else {
            return false
        }
        if methodType.name == AWXApplePayKey || methodType.name == AWXCardKey,
           let session = Session(session) {
            // we will eventually use Session on this branch
            if methodType.name == AWXCardKey {
                return CardProvider.canHandle(session, paymentMethod: methodType)
            } else {
                return ApplePayProvider.canHandle(session, paymentMethod: methodType)
            }
        } else {
            // fallback to use legacy sessions for LPM method type or session which can not be converted to Session. (e.g. AWXRecurringSession)
            var legacySession = session
            if let session = legacySession as? Session {
                legacySession = session.convertToLegacySession()
            }
            guard let providerClass = ClassToHandleFlowForPaymentMethodType(methodType),
                  providerClass.canHandle(legacySession, paymentMethod: methodType) else {
                return false
            }
            
            if methodType.name == AWXWeChatPayKey {
                
#if canImport(WechatOpenSDKDynamic)
                return true
#else
                return false
#endif
            }
            return true
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
        let provider = providerFactory.applePayProvider(
            delegate: self,
            session: session,
            type: methodType
        )
        actionProvider = provider
        try provider.startPayment(cancelPaymentOnDismiss: cancelPaymentOnDismiss)
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
        try AWXCardProvider.validate(
            card: card,
            billing: billing,
            paymentMethodType: methodType,
            session: session
        )
        let provider = providerFactory.cardProvider(
            delegate: self,
            session: session,
            type: methodType
        )
        actionProvider = provider
        Task {
            await provider.confirmIntentWithCard(
                card,
                billing: billing,
                saveCard: saveCard
            )
        }
    }
    
    /// Initiates a payment using AWXPaymentConsent
    /// This method processes a payment using a previously obtained payment consent, which may require additional input such as a CVC.
    /// - Parameters:
    ///   - consent: The payment consent retrieved from the server, authorizing this transaction.
    ///   If The payment method details, which may require additional input such as a CVC for validation.
    func confirmConsentPayment(with consent: AWXPaymentConsent) throws {
        guard let unifiedSession = Session(session) else {
            throw ValidationError.invalidPayment(
                underlyingError: "Invalid session (payment intent required)".asError()
            )
        }
        try AWXCardProvider.validate(
            consent: consent,
            paymentMethodType: methodType,
            session: unifiedSession
        )
        // Simplified consent flow
        let cardProvider = providerFactory.cardProvider(
            delegate: self,
            session: unifiedSession,
            type: methodType
        )
        actionProvider = cardProvider
        Task {
            await cardProvider.confirmIntentWithConsent(consent)
        }
    }
    
    /// Initiates a payment using a consent ID.
    /// - Parameter consentId: The previously generated consent identifier.
    func confirmConsentPayment(withId consentId: String, requiresCVC: Bool = false) throws {
        guard let unifiedSession = Session(session) else {
            throw ValidationError.invalidPayment(
                underlyingError: "Invalid session (payment intent required)".asError()
            )
        }
        try AWXCardProvider.validate(
            consentId: consentId,
            paymentMethodType: methodType,
            session: unifiedSession
        )
        // Simplified consent flow
        let cardProvider = providerFactory.cardProvider(
            delegate: self,
            session: unifiedSession,
            type: methodType
        )
        actionProvider = cardProvider
        Task {
            await cardProvider.confirmIntentWithConsent(consentId, requiresCVC: requiresCVC)
        }
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - name: The name of the payment method, as defined by the payment platform.
    ///   - additionalInfo: A dictionary containing any additional data required for processing the payment.
    func confirmRedirectPayment(with name: String, additionalInfo: [String: String]?) throws {
        let redirectAction = providerFactory.redirectProvider(
            delegate: self,
            session: session,
            type: methodType
        )
        try redirectAction.validate(name: name)
        actionProvider = redirectAction
        redirectAction.confirmPaymentIntent(with: name, additionalInfo: additionalInfo)
    }
    
    /// Initiates a schema-based payment transaction.
    /// This method processes a payment with schema-based payment methods such as digital wallets or bank transfers.
    /// You should collect all information from your user before calling this api
    /// - Parameters:
    ///   - paymentMethod: The payment method details, pre-validated with all required information.
    func confirmRedirectPayment(with paymentMethod: AWXPaymentMethod) throws {
        let redirectAction = providerFactory.redirectProvider(
            delegate: self,
            session: session,
            type: methodType
        )
        try redirectAction.validate(name: paymentMethod.type)
        actionProvider = redirectAction
        redirectAction.confirmPaymentIntent(with: paymentMethod, paymentConsent: nil)
    }
    
    private func handleFailure(_ paymentResultDelegate: AWXPaymentResultDelegate?,
                               _ error: Error) {
        let error = ValidationError.invalidPayment(underlyingError: error)
        debugLog("\(error)")
        paymentResultDelegate?.paymentViewController(nil, didCompleteWith: .failure, error: error)
        AnalyticsLogger.log(error: error)
    }
}

extension PaymentSessionHandler: AWXProviderDelegate {
    public func providerDidStartRequest(_ provider: AWXDefaultProvider) {
        debugLog("Provider: \(type(of: provider))")
        viewController.startLoading()
    }
    
    public func providerDidEndRequest(_ provider: AWXDefaultProvider) {
        debugLog("Provider: \(type(of: provider))")
        viewController.stopLoading()
    }
    
    public func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        debugLog("Provider: \(type(of: provider)), paymentIntentId: \(paymentIntentId)")
        session.updateInitialPaymentIntentId(paymentIntentId)
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWithPaymentConsentId paymentConsentId: String) {
        debugLog("Provider: \(type(of: provider)), paymentConsentId: \(paymentConsentId)")
        paymentResultDelegate?.paymentViewController?(viewController, didCompleteWithPaymentConsentId: paymentConsentId)
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        if status == .cancel {
            // only log payment_canceled here
            // payment_success and error event are logged in AWXDefaultProvider
            AnalyticsLogger.log(action: .paymentCanceled)
        }
        debugLog("Provider: \(type(of: provider)), stauts: \(status), error: \(error?.localizedDescription ?? "N/A")")
        if let dismissAction {
            if let methodType, methodType.name == AWXApplePayKey, status == .inProgress {
                // Remain in PaymentViewController when the Apple Pay status is .inProgress for UI integration
                // This status typically occurs when the user forcefully dismisses the PKPaymentAuthorizationController—
                // for example, by backgrounding the app—after successfully authorizing the payment.
                return
            }
            let viewController = self.viewController
            dismissAction {
                self.paymentResultDelegate?.paymentViewController(viewController, didCompleteWith: status, error: error)
            }
            self.dismissAction = nil
        } else {
            paymentResultDelegate?.paymentViewController(viewController, didCompleteWith: status, error: error)
        }
        // log success
        if status == .success {
            if let name = methodType?.name {
                AnalyticsLogger.log(
                    action: .paymentSuccess,
                    extraInfo: [.paymentMethod : name]
                )
            } else {
                AnalyticsLogger.log(action: .paymentSuccess)
            }
            
        }
        AnalyticsLogger.shared().session = nil
    }
    
    public func hostViewController() -> UIViewController {
        return viewController
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction) {
        debugLog("Provider: \(type(of: provider)), nextAction: \(nextAction.debugDescription)")
        guard let actionProviderClass = ClassToHandleNextActionForType(nextAction) as? AWXDefaultActionProvider.Type else {
            let error = NSError(
                domain: AWXSDKErrorDomain,
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No provider matched the next action."
                ]
            )
            paymentResultDelegate?.paymentViewController(viewController, didCompleteWith: .failure, error: error)
            return
        }
        let actionHandler = actionProviderClass.init(delegate: self, session: session)
        actionHandler.paymentConsent = provider.paymentConsent
        actionHandler.handle(nextAction)
        actionProvider = actionHandler
    }
    
    public func provider(_ provider: AWXDefaultProvider, shouldInsert controller: UIViewController) {
        debugLog("Provider: \(type(of: provider))")
        viewController.addChild(controller)
        controller.view.frame = viewController.view.frame.insetBy(dx: 0, dy: viewController.view.frame.maxY)
        viewController.view.addSubview(controller.view)
        controller.didMove(toParent: viewController)
    }
    
    public func provider(_ provider: AWXDefaultProvider,
                         shouldPresent controller: UIViewController?,
                         forceToDismiss: Bool,
                         withAnimation: Bool) {
        debugLog("Provider: \(type(of: provider))")
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
