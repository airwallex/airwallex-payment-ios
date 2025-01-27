//
//  PaymentUISessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

public class PaymentUISessionHandler: NSObject {
    
    var showCardDirectly = false
    
    private(set) var session: AWXSession
    
    private var actionProvider: AWXDefaultProvider!
    
    /// how to avoid force unwrap here
    weak var viewController: UIViewController!
    
    private var paymentConsent: AWXPaymentConsent?
    
    public init?(session: AWXSession,
          methodType: AWXPaymentMethodType,
          viewController: UIViewController) {
        self.session = session
        self.viewController = viewController
        
        guard let actionProviderClass = ClassToHandleFlowForPaymentMethodType(methodType) as? AWXDefaultProvider.Type else {
            return nil
        }
        super.init()
        actionProvider = actionProviderClass.init(delegate: self, session: session, paymentMethodType: methodType)
    }
    
    public init(session: AWXSession,
         paymentConsent: AWXPaymentConsent,
         viewController: UIViewController) {
        self.session = session
        self.viewController = viewController
        self.paymentConsent = paymentConsent
        super.init()
        actionProvider = AWXDefaultProvider(delegate: self, session: session)
    }
    
    /// This init method typically works with low-level API integration for now.
    /// - Parameters:
    ///   - session: payment session
    ///   - viewController: hosting view controller - where the payment launched
    ///   - actionProviderCreater: a closure to create/start/return a provider for the payment
    public init(session: AWXSession,
         viewController: UIViewController,
         actionProviderCreater: (PaymentUISessionHandler) -> AWXDefaultProvider) {
        self.session = session
        self.viewController = viewController
        super.init()
        self.actionProvider = actionProviderCreater(self)
    }
    
    func startPayment() {
        if let paymentMethod = paymentConsent?.paymentMethod {
            actionProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: paymentConsent)
        } else {
            actionProvider.handleFlow()
        }
    }
    
    public func startPayment(card: AWXCard, billing: AWXPlaceDetails?, saveCard: Bool = false) {
        guard let actionProvider = actionProvider as? AWXCardProvider else { return }
        actionProvider.confirmPaymentIntent(with: card, billing: billing, saveCard: saveCard)
    }
}

extension PaymentUISessionHandler: AWXProviderDelegate {
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
        AWXUIContext.shared().delegate?.paymentViewController?(viewController, didCompleteWithPaymentConsentId: paymentConsentId)
    }
    
    public func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        debugLog("stauts: \(status), error: \(error?.localizedDescription ?? "")")
        AWXUIContext.shared().delegate?.paymentViewController(viewController, didCompleteWith: status, error: error)
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
            if controller is AWXCardViewController && showCardDirectly {
                viewController.navigationController?.pushViewController(controller, animated: withAnimation)
            } else {
                viewController.present(controller, animated: withAnimation)
            }
        }
    }
}

private extension PaymentUISessionHandler {
    
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
        NSObject.logMesage("----Airwallex SDK----\(file)----\(functionName)----\(line)---\n \(message))")
    }
}

extension NSObject: SwiftLoggable {}
