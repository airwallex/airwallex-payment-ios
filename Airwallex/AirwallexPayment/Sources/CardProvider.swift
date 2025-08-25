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

class CardProvider: AWXDefaultProvider {
    
    override class func canHandle(_ session: AWXSession, paymentMethod: AWXPaymentMethodType) -> Bool {
        paymentMethod.name == AWXCardKey && paymentMethod.cardSchemes.count > 0
    }
    
    init(delegate: any AWXProviderDelegate, session: Session, methodType: AWXPaymentMethodType?) {
        super.init(delegate: delegate, session: session, paymentMethodType: methodType)
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
    
    // MARK: - Payment Consent Confirmation
    
    /// Confirms a payment intent using an existing payment consent
    /// - Parameter consent: The payment consent to use for confirmation
    func confirmIntentWithConsent(_ consent: AWXPaymentConsent) {
        // Create a task that can be cancelled if needed
        Task { @MainActor in
            do {
                let methodId = consent.paymentMethod?.id
                var cvc = consent.paymentMethod?.card?.cvc
                // Collect CVC if needed for PAN cards
                if let card = consent.paymentMethod?.card,
                   card.numberType == "PAN" && (cvc ?? "").isEmpty {
                    cvc = try await collectCVC(for:consent)
                }
                if let options = unifiedSession.recurringOptions {
                    // Create consent & confirm payment with existing payment method
                    confirmConsentConversion(methodId: methodId, cvc: cvc)
                } else if consent.isMITConsent {
                    // CIT transaction with MIT consent
                    unifiedSession.recurringOptions = RecurringOptions(nextTriggeredBy: .customerType)
                    confirmConsentConversion(methodId: methodId, cvc: cvc)
                } else {
                    // CIT transaction with CIT consent
                    confirmSubsequentTransaction(consentId: consent.id, cvc: cvc)
                }
            } catch {
                if Task.isCancelled {
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
    @MainActor private func collectCVC(for consent: AWXPaymentConsent) async throws -> String {
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
    
    func confirmIntentWithConsent(_ consentId: String, requiresCVC: Bool = false) {
        if requiresCVC {
            Task { @MainActor in
                do {
                    let consent = AWXPaymentConsent()
                    consent.id = consentId
                    let cvc = try await collectCVC(for: consent)
                    confirmSubsequentTransaction(consentId: consentId, cvc: cvc)
                } catch {
                    if Task.isCancelled {
                        delegate?.provider(self, didCompleteWith: .cancel, error: nil)
                    } else {
                        delegate?.provider(self, didCompleteWith: .failure, error: error)
                    }
                }
            }
        } else {
            confirmSubsequentTransaction(consentId: consentId, cvc: nil)
        }
    }
}
