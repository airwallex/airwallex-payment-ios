//
//  PaymentUISessionHandler.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/13.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit

class PaymentUISessionHandler: NSObject {
    
    var showCardDirectly = false
    
    private(set) var session: AWXSession
    
    private var actionProvider: AWXDefaultProvider!
    
    /// how to avoid force unwrap here
    weak var viewController: AWXViewController!
    
    private var paymentConsent: AWXPaymentConsent?
    
    init?(session: AWXSession,
         methodType: AWXPaymentMethodType,
         viewController: AWXViewController) {
        self.session = session
        self.viewController = viewController
        
        guard let actionProviderClass = ClassToHandleFlowForPaymentMethodType(methodType) as? AWXDefaultProvider.Type else {
            return nil
        }
        super.init()
        actionProvider = actionProviderClass.init(delegate: self, session: session, paymentMethodType: methodType)
    }
    
    init(session: AWXSession,
         paymentConsent: AWXPaymentConsent,
         viewController: AWXViewController) {
        self.session = session
        self.viewController = viewController
        self.paymentConsent = paymentConsent
        
        super.init()
        actionProvider = AWXDefaultProvider(delegate: self, session: session)
    }
    
    func startPayment() {
        if let paymentMethod = paymentConsent?.paymentMethod {
            actionProvider.confirmPaymentIntent(with: paymentMethod, paymentConsent: paymentConsent)
        } else {
            actionProvider.handleFlow()
        }
    }
}

extension PaymentUISessionHandler: AWXProviderDelegate {
    func providerDidStartRequest(_ provider: AWXDefaultProvider) {
        addlog()
        viewController.startAnimating()
    }
    
    func providerDidEndRequest(_ provider: AWXDefaultProvider) {
        addlog()
        viewController.stopAnimating()
    }
    
    func provider(_ provider: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String) {
        addlog("paymentIntentId: \(paymentIntentId)")
        session.updateInitialPaymentIntentId(paymentIntentId)
    }
    
    func provider(_ provider: AWXDefaultProvider, didCompleteWithPaymentConsentId paymentConsentId: String) {
        addlog("paymentConsentId: \(paymentConsentId)")
        AWXUIContext.shared().delegate?.paymentViewController?(viewController, didCompleteWithPaymentConsentId: paymentConsentId)
    }
    
    func provider(_ provider: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus, error: (any Error)?) {
        addlog("stauts: \(status), error: \(error?.localizedDescription ?? "")")
        AWXUIContext.shared().delegate?.paymentViewController(viewController, didCompleteWith: status, error: error)
    }
     
    func hostViewController() -> UIViewController {
        return viewController
    }

    func provider(_ provider: AWXDefaultProvider, shouldHandle nextAction: AWXConfirmPaymentNextAction) {
        guard let actionProviderClass = ClassToHandleNextActionForType(nextAction) as? AWXDefaultActionProvider.Type else {
            showAlert(NSLocalizedString("No provider matched the next action.", bundle: .payment, comment: ""))
            return
        }
        let actionHandler = actionProviderClass.init(delegate: self, session: session)
        actionHandler.handle(nextAction)
        actionProvider = actionHandler
    }
    
    func provider(_ provider: AWXDefaultProvider, shouldInsert controller: UIViewController) {
        viewController.addChild(controller)
        controller.view.frame = viewController.view.frame.insetBy(dx: 0, dy: viewController.view.frame.maxY)
        viewController.view.addSubview(controller.view)
        controller.didMove(toParent: viewController)
    }
    
    func provider(_ provider: AWXDefaultProvider, shouldPresent controller: UIViewController, forceToDismiss: Bool, withAnimation: Bool) {
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
    func addlog(_ message: String = "",
             file: String = #file,
             functionName: String = #function,
             line: Int = #line) {
        NSObject.logMesage("----Airwallex SDK----\(file)----\(functionName)----\(line)---\n \(message))")
    }
}

extension NSObject: SwiftLoggable {}
