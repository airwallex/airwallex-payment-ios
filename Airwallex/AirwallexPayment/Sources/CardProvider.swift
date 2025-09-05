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

class CardProvider: PaymentProvider {
    
    override class func canHandle(_ session: AWXSession, paymentMethod: AWXPaymentMethodType) -> Bool {
        guard session is Session else {
            return false
        }
        do {
            try AWXCardProvider.validateMethodTypeAndSession(paymentMethodType: paymentMethod, session: session)
            return true
        } catch {
            return false
        }
    }
    
    func confirmIntentWithCard(_ card: AWXCard,
                               billing: AWXPlaceDetails? = nil,
                               saveCard: Bool) async {
        debugLog("Start payment confirm. Type: Card. Intent Id: \(unifiedSession.paymentIntent.id)")
        let method = AWXPaymentMethod()
        method.type = AWXCardKey
        method.billing = billing
        method.card = card
        method.customerId = unifiedSession.paymentIntent.customerId
        
        if saveCard && unifiedSession.paymentIntent.customerId != nil {
            unifiedSession.recurringOptions = RecurringOptions(nextTriggeredBy: .customerType)
        }
        
        let request = createConfirmIntentRequest(method: method, consent: nil)
        await confirmIntent(request)
    }
    
    /// Confirms a payment intent using an existing payment consent
    /// - Parameter consent: The payment consent to use for confirmation
    func confirmIntentWithConsent(_ consent: AWXPaymentConsent) async {
        
        do {
            let methodId = consent.paymentMethod?.id
            var cvc = consent.paymentMethod?.card?.cvc
            // Collect CVC if needed for PAN cards
            if let card = consent.paymentMethod?.card,
               card.numberType == "PAN" && (cvc ?? "").isEmpty {
                cvc = try await collectCVC(for:consent)
            }
            if let methodId {
                if unifiedSession.recurringOptions != nil {
                    // Create consent & confirm payment with existing payment method
                    let request = createRequestForConsentConversion(methodId: methodId, cvc: cvc)
                    await confirmIntent(request)
                } else if consent.isMITConsent {
                    // CIT transaction with MIT consent
                    unifiedSession.recurringOptions = RecurringOptions(nextTriggeredBy: .customerType)
                    let request = createRequestForConsentConversion(methodId: methodId, cvc: cvc)
                    await confirmIntent(request)
                } else {
                    // CIT transaction with CIT consent
                    let request = createRequestForSubsequentTransaction(consentId: consent.id, cvc: cvc)
                    await confirmIntent(request)
                }
            } else {
                // CIT transaction with CIT consent
                let request = createRequestForSubsequentTransaction(consentId: consent.id, cvc: cvc)
                await confirmIntent(request)
            }
        } catch {
            await MainActor.run {
                if error is CancellationError {
                    delegate?.provider(self, didCompleteWith: .cancel, error: nil)
                } else {
                    delegate?.provider(self, didCompleteWith: .failure, error: error)
                }
            }
        }
    }
    
    func confirmIntentWithConsent(_ consentId: String, requiresCVC: Bool = false) async {
        do {
            var cvc: String? = nil
            if requiresCVC {
                cvc = try await collectCVC()
            }
            let request = createRequestForSubsequentTransaction(consentId: consentId, cvc: cvc)
            await confirmIntent(request)
        } catch {
            await MainActor.run {
                if error is CancellationError {
                    delegate?.provider(self, didCompleteWith: .cancel, error: nil)
                } else {
                    delegate?.provider(self, didCompleteWith: .failure, error: error)
                }
            }
        }
    }
    
    /// Collects CVC for a card that requires it
    /// - Parameters:
    ///   - card: The card to collect CVC for
    ///   - consent: The associated payment consent
    @MainActor private func collectCVC(for consent: AWXPaymentConsent? = nil) async throws -> String {
        guard let hostVC = delegate?.hostViewController?() else {
            throw "Host view controller not found".asError()
        }
        
        let cvc: String = try await withCheckedThrowingContinuation { continuation in
            let controller = AWXCardCVCViewController(nibName: nil, bundle: nil)
            controller.session = session
            controller.paymentConsent = consent
            controller.cvcCallback = { cvc, cancelled in
                if cancelled {
                    continuation.resume(throwing: CancellationError())
                } else {
                    continuation.resume(returning: cvc)
                }
            }
            let nav = UINavigationController(rootViewController: controller)
            nav.isModalInPresentation = true
            hostVC.present(nav, animated: true)
        }
        
        return cvc
    }
}

extension CardProvider {
    
    func createRequestForSubsequentTransaction(consentId: String, cvc: String?) -> AWXConfirmPaymentIntentRequest {
        let consent = AWXPaymentConsent()
        consent.id = consentId
        var method: AWXPaymentMethod?
        if let cvc {
            method = AWXPaymentMethod()
            method?.type = AWXCardKey
            method?.card = AWXCard()
            method?.card?.cvc = cvc
        }
        return createConfirmIntentRequest(method: method, consent: consent)
    }
    
    func createRequestForConsentConversion(methodId: String?, cvc: String?) -> AWXConfirmPaymentIntentRequest {
        let method = AWXPaymentMethod()
        method.id = methodId
        method.type = AWXCardKey
        if let cvc {
            method.card = AWXCard()
            method.card?.cvc = cvc
        }
        return createConfirmIntentRequest(method: method, consent: nil)
    }
    
}
