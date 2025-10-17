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
    ///   - consentOptions: The associated PaymentConsent to set up along with the PaymentIntent. Optional
    /// - Returns: request object
    func createConfirmIntentRequest(method: AWXPaymentMethod?,
                                    consent: AWXPaymentConsent?,
                                    consentOptions: PaymentConsentOptions?) -> AWXConfirmPaymentIntentRequest {
        assert(method != nil || consent != nil)
        let request = AWXConfirmPaymentIntentRequest()
        request.intentId = unifiedSession.paymentIntent.id
        request.customerId = unifiedSession.paymentIntent.customerId
        request.paymentMethod = method
        request.paymentConsent = consent
        request.device = AWXDevice.withRiskSessionId()
        request.consentOptions = consentOptions?.encodeToJSON()
        // TODO: Currently hardcoded to AWXThreeDSReturnURL for Apple Pay and Card payments (3DS webView interception).
        // When LPM supports simplified consent flow, check payment method type and use session.returnURL for redirect payments.
        request.returnURL = AWXThreeDSReturnURL
        if let method {
            request.options = createPaymentMethodOptions(method)
        }
        return request
    }
    
    @MainActor func confirmIntent(_ request: AWXConfirmPaymentIntentRequest) async {
        do {
            self.delegate?.providerDidStartRequest(self)
            let response: AWXConfirmPaymentIntentResponse = try await apiClient.sendRequest(request)
            complete(with: response, error: nil)
        } catch {
            complete(with: nil, error: error)
        }
    }
}

extension PaymentProvider {
    
    func createPaymentMethodOptions(_ paymentMethod: AWXPaymentMethod) -> AWXPaymentMethodOptions? {
        guard [AWXApplePayKey, AWXCardKey].contains(paymentMethod.type) else {
            return nil
        }
        let cardOptions = AWXCardOptions()
        cardOptions.autoCapture = unifiedSession.autoCapture
        if paymentMethod.type == AWXCardKey {
            cardOptions.threeDs = AWXThreeDs()
            cardOptions.threeDs?.returnURL = AWXThreeDSReturnURL
        }
        
        let options = AWXPaymentMethodOptions()
        options.cardOptions = cardOptions
        return options
    }
}
