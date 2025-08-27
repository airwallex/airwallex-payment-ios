//
//  ApplePayProvider.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 21/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//


#if canImport(AirwallexCore)
import AirwallexCore
#endif
import AirwallexRisk
import Foundation
import PassKit

/// `ApplePayProvider` is a Swift implementation of the Apple Pay payment provider.
/// It handles payment method with Apple Pay, providing a more Swift-idiomatic interface
/// while preserving all functionality of the Objective-C AWXApplePayProvider.
class ApplePayProvider: AWXDefaultProvider {
    
    /// Represents the current state of the Apple Pay payment flow
    private enum PaymentState {
        /// initial status
        case notPresented
        /// payment sheet displayed but not authorized
        case notStarted
        /// payment authorized but payment intent not confirmed
        case pending
        /// payment complete with success or failure
        case complete
    }
    
    /// Indicates whether Apple Pay was launched directly
    private var cancelPaymentOnDismiss = false
    
    /// Indicates whether a presentation failure has already been handled
    private var didHandlePresentationFail = false
    
    /// The current state of the payment process
    private var paymentState: PaymentState = .notPresented
    
    /// Result of confirm intent
    private var result: Result<AWXConfirmPaymentIntentResponse, Error>?
    
    /// Determines if the provider can handle the given session and payment method
    /// - Parameters:
    ///   - session: The session to check
    ///   - paymentMethod: The payment method to check
    /// - Returns: True if the provider can handle the session and payment method
    override class func canHandle(_ session: AWXSession, paymentMethod: AWXPaymentMethodType) -> Bool {
        guard session is Session else {
            return false
        }
        do {
            try AWXApplePayProvider.validate(paymentMethodType: paymentMethod, session: session)
            return true
        } catch {
            return false
        }
    }
    
    init(delegate: any AWXProviderDelegate, session: Session, methodType: AWXPaymentMethodType?) {
        super.init(delegate: delegate, session: session, paymentMethodType: methodType)
    }
    
    /// Launch Apple Pay sheet to confirm the payment intent
    func startPayment(cancelPaymentOnDismiss: Bool = true) throws {
        try AWXApplePayProvider.validate(paymentMethodType: paymentMethodType, session: unifiedSession)
        paymentState = .notPresented
        didHandlePresentationFail = false
        self.cancelPaymentOnDismiss = cancelPaymentOnDismiss
        
        let request = try unifiedSession.makePaymentRequestOrError()
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        
        Task { @MainActor in
            delegate?.providerDidStartRequest(self)
            let presented = await controller.present()
            guard presented else {
                handlePresentationFail()
                return
            }
            
            // Log risk event
            RiskLogger.log(.showApplePay, screen: .applePay)
            debugLog("Show apple pay")
            paymentState = .notStarted
            AnalyticsLogger.log(
                pageView: .applePaySheet,
                extraInfo: [
                    .supportedNetworks : unifiedSession.applePayOptions?.supportedNetworks ?? []
                ]
            )
        }
    }
    
    /// Handle a failure to present the Apple Pay sheet
    private func handlePresentationFail() {
        if !didHandlePresentationFail {
            didHandlePresentationFail = true
            let error = "Failed to present Apple Pay Controller.".asError()
            AnalyticsLogger.log(errorName: "apple_pay_sheet", errorMessage: error.rawValue)
            delegate?.provider(self, didCompleteWith: .failure, error: error)
        }
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayProvider: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult {
        debugLog()
        let method = AWXPaymentMethod()
        method.type = AWXApplePayKey
        method.customerId = unifiedSession.customerId()
        
        let billingPayload = payment.billingContact?.payloadForRequest()
        do {
            let applePayParams = try payment.token.payloadForRequest(withBilling: billingPayload)
            method.appendAdditionalParams(applePayParams)
            paymentState = .pending
            let response = try await confirmIntent(method: method)
            paymentState = .complete
            result = Result.success(response)
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        } catch {
            paymentState = .complete
            result = Result.failure(error)
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        debugLog()
        Task { @MainActor in
            await controller.dismiss()
            switch paymentState {
            case .notPresented:
                debugLog("Apple pay sheet did finished at not presented status")
                handlePresentationFail()
            case .notStarted:
                debugLog("Apple pay sheet did finished at not started status (cancelled)")
                if cancelPaymentOnDismiss {
                    delegate?.provider(self, didCompleteWith: .cancel, error: nil)
                }
            case .pending:
                debugLog("Apple pay sheet did finished at pending status (confirming payment intent)")
                // If UI disappears during the interaction with our API, we pass the state to the upper level
                // so in progress UI can be handled before we get the confirmed or failed intent
                delegate?.provider(self, didCompleteWith: .inProgress, error: nil)
            case .complete:
                debugLog("Apple pay sheet did finished at complete status (success or failed)")
                guard let result else {
                    assert(false, "should never happen")
                    delegate?.provider(self, didCompleteWith: .failure, error: nil)
                    return
                }
                switch result {
                case .success(let response):
                    complete(with: response, error: nil)
                case .failure(let error):
                    complete(with: nil, error: error)
                }
                break
            }
        }
    }
}
