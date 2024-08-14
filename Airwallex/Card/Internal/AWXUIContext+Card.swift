//
//  AWXUIContext+Card.swift
//  Card
//
//  Created by Tony He (CTR) on 2024/7/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

private var associatedHostVCKey: UInt8 = 0
private var associatedIsFlowFromPushKey: UInt8 = 1

@objc public extension AWXUIContext {
    private var hostVC: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &associatedHostVCKey) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &associatedHostVCKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var isFlowFromPush: Bool {
        get {
            return objc_getAssociatedObject(self, &associatedIsFlowFromPushKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &associatedIsFlowFromPushKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /**
     Present the payment flow from card info collection view.
     */
    func presentCardPaymentFlowFrom(_ hostViewController: UIViewController, cardSchemes: [AWXCardBrand] = AWXAllCardBrand()) {
        isFlowFromPush = false
        hostVC = hostViewController
        let provider = AWXCardProvider(delegate: self, session: session, paymentMethodType: nil, isFlowFromPushing: false)
        provider.cardSchemes = cardSchemes
        provider.showPaymentDirectly = true
        provider.handleFlow()
    }

    /**
     Push the payment flow from card info collection view.
     */
    func pushCardPaymentFlowFrom(_ hostViewController: UIViewController, cardSchemes: [AWXCardBrand] = AWXAllCardBrand()) {
        isFlowFromPush = true
        hostVC = hostViewController
        let provider = AWXCardProvider(delegate: self, session: session, paymentMethodType: nil, isFlowFromPushing: true)
        provider.cardSchemes = cardSchemes
        provider.showPaymentDirectly = true
        provider.handleFlow()
    }
}

@objc extension AWXUIContext: AWXProviderDelegate {
    public func providerDidStartRequest(_: AWXDefaultProvider) {
        logMessage("providerDidStartRequest:")
    }

    public func providerDidEndRequest(_: AWXDefaultProvider) {
        logMessage("providerDidEndRequest:")
    }

    public func provider(
        _: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus,
        error: (any Error)?
    ) {
        logMessage(
            "provider:didCompleteWithStatus:error:  \(status)  \(error?.localizedDescription ?? "")")
    }

    public func provider(
        _: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String
    ) {
        session.updateInitialPaymentIntentId(paymentIntentId)
        logMessage("provider:didInitializePaymentIntentId:  \(paymentIntentId)")
    }

    public func provider(
        _: AWXDefaultProvider, shouldPresent controller: UIViewController?,
        forceToDismiss: Bool, withAnimation: Bool
    ) {
        if forceToDismiss {
            controller?.presentedViewController?.dismiss(
                animated: true,
                completion: {
                    if let vc = controller {
                        self.hostVC?.present(vc, animated: withAnimation)
                    }
                }
            )
        } else if let vc = controller {
            if isFlowFromPush {
                let navi = hostVC as? UINavigationController ?? hostVC?.navigationController
                navi?.pushViewController(vc, animated: withAnimation)
            } else {
                hostVC?.present(vc, animated: withAnimation)
            }
        }
    }
}
