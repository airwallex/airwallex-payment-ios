//
//  PaymentSessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public class PaymentSessionHandler: NSObject {
    
    private(set) var session: AWXSession
    
    private var actionProvider: AWXDefaultProvider!
    
    weak var viewController: UIViewController!

    private var paymentResultDelegate: AWXPaymentResultDelegate? {
        (viewController as? AWXPaymentResultDelegate) ?? AWXUIContext.shared().delegate
    }
    
    /// Initializes a `PaymentSessionHandler` with a payment session and the view controller from which the payment is initiated.
    /// - Parameters:
    ///   - session: The payment session.
    ///   - viewController: The view controller from which the payment is initiated.
    public init(session: AWXSession, viewController: UIViewController) {
        self.session = session
        self.viewController = viewController
    }
    
    /// Initializes a `PaymentSessionHandler` with a payment session and a view controller that also acts as a payment result delegate.
    /// - Parameters:
    ///   - session: The payment session.
    ///   - viewController: The view controller from which the payment is initiated, conforming to `AWXPaymentResultDelegate` to handle payment results.
    public init(session: AWXSession, viewController: UIViewController & AWXPaymentResultDelegate) {
        self.session = session
        self.viewController = viewController
    }
    
    public func startApplePay(methodType: AWXPaymentMethodType? = nil) {
        let applePayProvider = AWXApplePayProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = applePayProvider
        applePayProvider.startPayment()
    }
    
    public func startCardPayment(with card: AWXCard,
                                 billing: AWXPlaceDetails?,
                                 saveCard: Bool = false,
                                 methodType: AWXPaymentMethodType? = nil) {
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session,
            paymentMethodType: methodType
        )
        actionProvider = cardProvider
        cardProvider.confirmPaymentIntent(with: card, billing: billing, saveCard: saveCard)
    }
    
    public func startConsentPayment(with consent: AWXPaymentConsent, paymentMethod: AWXPaymentMethod) {
        let cardProvider = AWXCardProvider(
            delegate: self,
            session: session
        )
        actionProvider = cardProvider
        cardProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: consent)
    }
    
    public func startSchemaPayment(with paymentMethod: AWXPaymentMethod, methodType: AWXPaymentMethodType? = nil) {
        let schemaProvider = AWXSchemaProvider(delegate: self, session: session, paymentMethodType: methodType)
        actionProvider = schemaProvider
        schemaProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: nil)
    }
    
    public func startSchemaPayment(with name: String, additionalInfo: [String: String]?) {
        let redirectAction = AWXRedirectActionProvider(delegate: self, session: session)
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
        debugLog("stauts: \(status), error: \(error)")
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
            showAlert(NSLocalizedString("No provider matched the next action.", bundle: .payment, comment: ""))
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

private extension PaymentSessionHandler {
    
    func showAlert(_ message: String) {
        let alertVC = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: NSLocalizedString("Close", bundle: .payment, comment: ""),
            style: .cancel,
            handler: nil
        )
        alertVC.addAction(action)
        viewController.present(alertVC, animated: true)
    }
}

protocol SwiftLoggable {}

extension SwiftLoggable {
    func debugLog(_ message: String = "",
                  file: String = #file,
                  functionName: String = #function,
                  line: Int = #line) {
        NSObject.logMesage("----Airwallex SDK----\(Date())---\n\(file)\n---\(functionName)-line: \(line)-\n---\(message)")
    }
}

extension NSObject: SwiftLoggable {}
