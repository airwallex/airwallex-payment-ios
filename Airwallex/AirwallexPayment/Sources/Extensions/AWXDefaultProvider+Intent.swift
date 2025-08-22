//
//  AWXDefaultProvider+Intent.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 18/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import UIKit

extension AWXDefaultProvider {
    
    var unifiedSession: Session {
        session as! Session
    }
    
    func confirmIntent(method: AWXPaymentMethod? = nil,
                       consent: AWXPaymentConsent? = nil) async throws -> AWXConfirmPaymentIntentResponse {
        let request = AWXConfirmPaymentIntentRequest()
        request.intentId = unifiedSession.paymentIntent.id
        request.customerId = unifiedSession.paymentIntent.customerId
        request.paymentMethod = method
        request.paymentConsent = consent
        request.device = AWXDevice.withRiskSessionId()
        request.consentOptions = unifiedSession.recurringOptions?.encodeToJSON()
        request.returnURL = AWXThreeDSReturnURL
        if let method {
            request.options = createPaymentMethodOptions(method)
        }
        return try await sendRequest(request)
    }
    
    func confirmInitialTransaction(_ method: AWXPaymentMethod) {
        confirmIntent(method: method)
    }
    
    func confirmSubsequentTransaction(consentId: String, cvc: String?) {
        let consent = AWXPaymentConsent()
        consent.id = consentId
        // for now all subsequent transactions's type are card
        let method = AWXPaymentMethod()
        method.type = AWXCardKey
        if let cvc {
            method.card = AWXCard()
            method.card?.cvc = cvc
        }
        confirmIntent(method: method, consent: consent)
    }
    
    func confirmConsentConversion(methodId: String?, cvc: String?) {
        // for now all conversion transactions's type are card
        let method = AWXPaymentMethod()
        method.id = methodId
        method.type = AWXCardKey
        if let cvc {
            method.card = AWXCard()
            method.card?.cvc = cvc
        }
        confirmIntent(method: method)
    }
}

fileprivate extension AWXDefaultProvider {
    
    func createPaymentMethodOptions(_ paymentMethod: AWXPaymentMethod) -> AWXPaymentMethodOptions? {
        guard [AWXApplePayKey, AWXCardKey].contains(paymentMethod.type) else {
            return nil
        }
        let cardOptions = AWXCardOptions()
        cardOptions.autoCapture = unifiedSession.autoCapture
        if paymentMethod.type == AWXCardKey {
            let threeDS = AWXThreeDs()
            threeDS.returnURL = AWXThreeDSReturnURL
            cardOptions.threeDs = threeDS
        }
        
        let options = AWXPaymentMethodOptions()
        options.cardOptions = cardOptions
        return options
    }
    
    func confirmIntent(method: AWXPaymentMethod? = nil,
                               consent: AWXPaymentConsent? = nil) {
        Task { @MainActor in
            do {
                self.delegate?.providerDidStartRequest(self)
                let response: AWXConfirmPaymentIntentResponse = try await confirmIntent(
                    method: method,
                    consent: consent
                )
                complete(with: response, error: nil)
            } catch {
                complete(with: nil, error: error)
            }
        }
    }
    
    func sendRequest<Req: AWXRequest, Res: AWXResponse>(_ request: Req) async throws -> Res {
        let apiClient = AWXAPIClient(configuration: .shared())
        guard let response = try await apiClient.send(request) as? Res else {
            throw NSError(
                domain: AWXSDKErrorDomain,
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "failed to parse response",
                    NSURLErrorFailingURLErrorKey: request.path()
                ]
            )
        }
        return response
    }
}
