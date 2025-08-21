//
//  PaymentProvider.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 18/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import UIKit

@_spi(AWX) public class PaymentProvider: AWXDefaultProvider {
    
    var unifiedSession: Session {
        session as! Session
    }
    
    public init(delegate: any AWXProviderDelegate,
                session: Session,
                paymentMethodType: AWXPaymentMethodType? = nil) {
        super.init(delegate: delegate, session: session, paymentMethodType: paymentMethodType)
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
    
    private func confirmIntent(method: AWXPaymentMethod? = nil, consent: AWXPaymentConsent? = nil) {
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
        Task { @MainActor in
            delegate?.providerDidStartRequest(self)
            do {
                let response: AWXConfirmPaymentIntentResponse = try await sendRequest(request)
                delegate?.providerDidEndRequest(self)
                complete(with: response, error: nil)
            } catch {
                delegate?.providerDidEndRequest(self)
                complete(with: nil, error: error)
            }
        }
    }
    
    func confirmInitialTransaction(_ method: AWXPaymentMethod) {
        confirmIntent(method: method)
    }
    
    func confirmSubsequentTransaction(consentId: String, cvc: String?) {
        let consent = AWXPaymentConsent()
        consent.id = consentId
        let method = AWXPaymentMethod()
        method.card = AWXCard()
        method.card?.cvc = cvc
        confirmIntent(method: method, consent: consent)
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
