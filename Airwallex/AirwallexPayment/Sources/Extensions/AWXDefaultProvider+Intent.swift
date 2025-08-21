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
    
    private func createPaymentMethodOptions(_ paymentMethod: AWXPaymentMethod) -> AWXPaymentMethodOptions? {
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
        Task { @MainActor in
            self.delegate?.providerDidStartRequest(self)
            do {
                let response = try await confirmIntent(method: method)
                complete(with: response, error: nil)
            } catch {
                complete(with: nil, error: error)
            }
        }
    }
    
    func confirmSubsequentTransaction(consentId: String, cvc: String?) {
        let consent = AWXPaymentConsent()
        consent.id = consentId
        let method = AWXPaymentMethod()
        method.card = AWXCard()
        method.card?.cvc = cvc
        Task { @MainActor in
            self.delegate?.providerDidStartRequest(self)
            do {
                let response = try await confirmIntent(method: method, consent: consent)
                complete(with: response, error: nil)
            } catch {
                complete(with: nil, error: error)
            }
        }
    }
    
    func confirmConsentConversion(methodId: String, cvc: String?) {
        // TODO: wpdebug
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
