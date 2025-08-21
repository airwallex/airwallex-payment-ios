//
//  CardProvider.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 20/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

@_spi(AWX) public class CardPaymentProvider: PaymentProvider {
    
    public override class func canHandle(_ session: AWXSession, paymentMethod: AWXPaymentMethodType) -> Bool {
        paymentMethod.cardSchemes.count != 0
    }
    
    func confirmIntentWithCard(_ card: AWXCard,
                               billing: AWXPlaceDetails? = nil,
                               saveCard: Bool) {
        debugLog("Start payment confirm. Type: Card. Intent Id: \(unifiedSession.paymentIntent.id)")
        var method = AWXPaymentMethod()
        method.type = AWXCardKey
        method.billing = billing
        method.card = card
        method.customerId = unifiedSession.paymentIntent.customerId
        
        if saveCard && unifiedSession.paymentIntent.customerId != nil {
            unifiedSession.recurringOptions = RecurringOptions(nextTriggeredBy: .customerType)
        }
        confirmInitialTransaction(method)
    }
    
    func confirmIntentWithConsent(_ consent: AWXPaymentConsent) {
        do {
            guard let card = consent.paymentMethod?.card else {
                throw "card information required".asError()
            }
            if card.numberType == "PAN" {
                guard let cvc = card.cvc, !cvc.isEmpty else {
                    let controller = AWXCardCVCViewController(nibName: nil, bundle: nil)
                    controller.session = session
                    controller.paymentConsent = consent
                    controller.cvcCallback = { cvc, cancelled in
                        if cancelled {
                            self.delegate?.provider(self, didCompleteWith: .cancel, error: nil)
                        } else {
                            self.confirmSubsequentTransaction(consentId: consent.id, cvc: cvc)
                        }
                    }
                    guard let hostVC = delegate?.hostViewController?() else {
                        throw "hostVC not found".asError()
                    }
                    let nav = UINavigationController(rootViewController: controller)
                    nav.isModalInPresentation = true
                    hostVC.present(nav, animated: true)
                    return
                }
            }
            confirmSubsequentTransaction(consentId: consent.id, cvc: card.cvc)
        } catch {
            delegate?.provider(self, didCompleteWith: .failure, error: error)
        }
    }
    
    func confirmIntentWithConsent(_ consentId: String) {
        confirmSubsequentTransaction(consentId: consentId, cvc: nil)
    }
}
