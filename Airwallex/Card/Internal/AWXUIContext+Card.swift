//
//  AWXUIContext+Card.swift
//  Card
//
//  Created by Tony He (CTR) on 2024/7/26.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objc public extension AWXUIContext {
    /**
     Present the payment flow from card info collection view.
     */

    func presentCardPaymentFlowFrom(_ hostViewController: UIViewController, cardSchemes: [Int]) {
        hostVC = hostViewController
        isPush = false
        let provider = AWXCardProvider(delegate: self, session: session)
        provider.cardSchemes = cardSchemes as [NSNumber]
        provider.handleFlow()
    }

    @nonobjc func presentCardPaymentFlowFrom(_ hostViewController: UIViewController, cardSchemes: [AWXBrandType] = AWXBrandType.allCases) {
        hostVC = hostViewController
        isPush = false
        let provider = AWXCardProvider(delegate: self, session: session)
        provider.cardSchemes = cardSchemes.map { $0.rawValue as NSNumber }
        provider.handleFlow()
    }

    /**
     Push the payment flow from card info collection view.
     */
    func pushCardPaymentFlowFrom(_ hostViewController: UIViewController, cardSchemes: [Int]) {
        hostVC = hostViewController
        isPush = true
        let provider = AWXCardProvider(delegate: self, session: session)
        provider.cardSchemes = cardSchemes as [NSNumber]
        provider.handleFlow()
    }

    @nonobjc func pushCardPaymentFlowFrom(_ hostViewController: UIViewController, cardSchemes: [AWXBrandType] = AWXBrandType.allCases) {
        hostVC = hostViewController
        isPush = true
        let provider = AWXCardProvider(delegate: self, session: session)
        provider.cardSchemes = cardSchemes.map { $0.rawValue as NSNumber }
        provider.handleFlow()
    }
}

@objc extension AWXUIContext: AWXProviderDelegate {
    public func providerDidStartRequest(_: AWXDefaultProvider) {
        logMessage("providerDidStartRequest:")
        currentVC?.startAnimating()
    }

    public func providerDidEndRequest(_: AWXDefaultProvider) {
        logMessage("providerDidEndRequest:")
        currentVC?.stopAnimating()
    }

    public func provider(
        _: AWXDefaultProvider, didCompleteWith status: AirwallexPaymentStatus,
        error: (any Error)?
    ) {
        logMessage(
            "provider:didCompleteWithStatus:error:  \(status)  \(error?.localizedDescription ?? "")")
        delegate?.paymentViewController(
            currentVC ?? UIViewController(), didCompleteWith: status, error: error
        )
        logMessage(
            "Delegate: \(delegate?.description ?? ""), paymentViewController:didCompleteWithStatus:error:  \(status)  \(error?.localizedDescription ?? "")"
        )
    }

    public func provider(_: AWXDefaultProvider, didCompleteWithPaymentConsentId Id: String) {
        delegate?.paymentViewController?(
            currentVC ?? UIViewController(), didCompleteWithPaymentConsentId: Id
        )
    }

    public func provider(
        _: AWXDefaultProvider, didInitializePaymentIntentId paymentIntentId: String
    ) {
        session.updateInitialPaymentIntentId(paymentIntentId)
        logMessage("provider:didInitializePaymentIntentId:  \(paymentIntentId)")
    }

    public func provider(
        _: AWXDefaultProvider, shouldHandle _: AWXConfirmPaymentNextAction
    ) {
        guard let currentVC = currentVC as? AWXCardViewController else { return }
        if let vm = currentVC.viewModel {
            let actionProvider = AWX3DSActionProvider(delegate: vm, session: session)
            vm.provider = actionProvider
        }
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
            if isPush {
                let navi = hostVC as? UINavigationController ?? hostVC?.navigationController
                navi?.pushViewController(vc, animated: withAnimation)
            } else {
                hostVC?.present(vc, animated: withAnimation)
            }
        }
    }
}
