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

/// Extension for handling simplified consent flow
class PaymentProvider: AWXDefaultProvider {
    
    let apiClient: AWXAPIClient
    
    /// Returns the current session cast as a `Session` type, used for the simplified consent flow.
    /// - Note: This property force casts `session` to `Session`. Ensure that `session` is always of type `Session` to avoid runtime crashes.
    /// Sesion that works with the simplified consent flow
    /// Only expected to be used by ApplePayProvider and CardProvider
    var unifiedSession: Session {
        session as! Session
    }
    
    init(delegate: any AWXProviderDelegate,
         session: Session,
         methodType: AWXPaymentMethodType?,
         apiClient: AWXAPIClient = AWXAPIClient.init(configuration: .shared())) {
        self.apiClient = apiClient
        super.init(delegate: delegate, session: session, paymentMethodType: methodType)
    }
    
    /// Confirms a payment intent by sending a request with the provided payment method and consent information.
    /// - Parameters:
    ///   - method: The payment method to use for confirming the intent. Optional.
    ///   - consent: The payment consent information. Optional.
    /// - Returns: A response object containing the result of the payment intent confirmation.
    /// - Throws: An error if the request fails or the confirmation cannot be completed.
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
    
    /// Confirms the initial transaction using the provided payment method.
    /// - Parameter method: The `AWXPaymentMethod` to be used for confirming the intent.
    func confirmInitialTransaction(_ method: AWXPaymentMethod) {
        confirmIntent(method: method)
    }
    
    /// Confirms a subsequent transaction using the provided consent ID and optional CVC code.
    /// - Parameters:
    ///   - consentId: The identifier for the payment consent.
    ///   - cvc: The card verification code (CVC) for the transaction, if required.
    /// - Note: Currently, all subsequent transactions are processed as card payments.
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
    
    /// Confirms a consent conversion transaction using the provided payment method ID and optional CVC code.
    /// - Parameters:
    ///   - methodId: The identifier of the payment method to use for the conversion.
    ///   - cvc: An optional card verification code (CVC) for the payment method.
    /// - Note: Currently, all conversion transactions are processed as card payments.
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

fileprivate extension PaymentProvider {
    
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
