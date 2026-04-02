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
import UIKit

/// `ApplePayProvider` is a Swift implementation of the Apple Pay payment provider.
/// It handles payment method with Apple Pay, providing a more Swift-idiomatic interface
/// while preserving all functionality of the Objective-C AWXApplePayProvider.
class ApplePayProvider: PaymentProvider {
    
    /// Represents the current state of the Apple Pay payment flow
    enum PaymentState {
        /// initial status
        case notPresented
        /// payment sheet displayed but not authorized
        case notStarted
        /// payment authorized but payment intent not confirmed
        case pending
        /// payment complete with success or failure
        case complete
    }
    
    /// Indicates whether a presentation failure has already been handled
    private var didHandlePresentationFail = false
    
    /// Indicates whether the apple pay sheet dismiss in .pending status
    /// which can happen when app accidentily go to background when apple pay authorized but
    /// provider still sending request for confirming payment intent, in this case we will not receive paymentAuthorizationControllerDidFinish
    /// callback after request complete, so we will depend on this flag to callback for payment status to delegate
    private var didDismissWhilePending = false
    
    /// The current state of the payment process
    private(set) var paymentState: PaymentState = .notPresented
    
    /// Result of confirm intent
    private var confirmIntentResponse: Result<AWXConfirmPaymentIntentResponse, Error>?
    
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
    
    private let paymentController: PKPaymentAuthorizationController.Type
    
    init(delegate: any AWXProviderDelegate,
         session: Session,
         methodType: AWXPaymentMethodType?,
         apiClient: AWXAPIClient = AWXAPIClient(configuration: .shared()),
         paymentController: PKPaymentAuthorizationController.Type = PKPaymentAuthorizationController.self) {
        self.paymentController = paymentController
        super.init(
            delegate: delegate,
            session: session,
            methodType: methodType,
            apiClient: apiClient
        )
    }
    
    /// Launch Apple Pay sheet to confirm the payment intent
    func startPayment() throws {
        try AWXApplePayProvider.validate(paymentMethodType: paymentMethodType, session: unifiedSession)
        paymentState = .notPresented
        didHandlePresentationFail = false
        didDismissWhilePending = false
        
        let request = try unifiedSession.makePaymentRequestOrError()

        /// PKPaymentAuthorizationController's initializer is nonnull,
        /// so use PKPaymentAuthorizationViewController intead
        guard PKPaymentAuthorizationViewController(paymentRequest: request) != nil else {
            let error = "Failed to initialize Apple Pay Controller.".asError()
            AnalyticsLogger.log(
                errorName: "apple_pay_sheet",
                errorMessage: error.rawValue,
                extraInfo: [
                    .supportedNetworks: request.supportedNetworks
                ]
            )
            delegate?.provider(self, didCompleteWith: .failure, error: error)
            return
        }
        let controller = paymentController.init(paymentRequest: request)
        controller.delegate = self
        
        Task { @MainActor in
            let presented = await controller.present()
            guard presented else {
                handlePresentationFail()
                return
            }
            delegate?.providerDidStartRequest(self)
            
            // Log risk event
            RiskLogger.log(.showApplePay, screen: .applePay)
            debugLog("Show apple pay")
            paymentState = .notStarted
            AnalyticsLogger.log(
                pageView: .applePaySheet,
                extraInfo: [
                    .supportedNetworks: unifiedSession.applePayOptions?.supportedNetworks ?? []
                ]
            )
        }
    }
    
    /// Handle a failure to present the Apple Pay sheet
    private func handlePresentationFail() {
        if !didHandlePresentationFail {
            didHandlePresentationFail = true
            let error = "Failed to present Apple Pay Controller.".asError()
            AnalyticsLogger.log(
                errorName: "apple_pay_sheet",
                errorMessage: error.rawValue,
                extraInfo: [
                    .supportedNetworks: unifiedSession.applePayOptions?.supportedNetworks ?? []
                ]
            )
            delegate?.provider(self, didCompleteWith: .failure, error: error)
        }
    }
    
    @MainActor func confirmIntent(payment: PKPayment) async -> PKPaymentAuthorizationResult {
        debugLog()
        let method = AWXPaymentMethod()
        method.type = AWXApplePayKey
        method.customerId = unifiedSession.customerId()
        
        let billingPayload = payment.billingContact?.payloadForRequest()
        do {
            let applePayParams = try payment.token.payloadForRequest(withBilling: billingPayload)
            method.appendAdditionalParams(applePayParams)
            paymentState = .pending
            let request = try await createConfirmIntentRequest(
                method: method,
                consent: nil,
                consentOptions: unifiedSession.paymentConsentOptions
            )
            let response: AWXConfirmPaymentIntentResponse = try await apiClient.sendRequest(request)
            confirmIntentResponse = Result.success(response)
            paymentState = .complete
            if didDismissWhilePending {
                complete(with: response, error: nil)
            }
            return PKPaymentAuthorizationResult(status: .success, errors: nil)
        } catch {
            confirmIntentResponse = Result.failure(error)
            paymentState = .complete
            if didDismissWhilePending {
                complete(with: nil, error: error)
            }
            return PKPaymentAuthorizationResult(status: .failure, errors: [error])
        }
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayProvider: PKPaymentAuthorizationControllerDelegate {

    func presentationWindow(for controller: PKPaymentAuthorizationController) -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment) async -> PKPaymentAuthorizationResult {
        await confirmIntent(payment: payment)
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        Task { @MainActor in
            await controller.dismiss()
            switch paymentState {
            case .notPresented:
                debugLog("Apple pay sheet did finished at not presented status")
                self.delegate?.providerDidEndRequest(self)
                handlePresentationFail()
            case .notStarted:
                debugLog("Apple pay sheet did finished at not started status (cancelled)")
                self.delegate?.providerDidEndRequest(self)
                delegate?.provider(self, didCompleteWith: .cancel, error: nil)
            case .pending:
                debugLog("Apple pay sheet did finished at pending status (confirming payment intent)")
                // If UI disappears during the interaction with our API, we pass the state to the upper level
                // so in progress UI can be handled before we get the confirmed or failed intent
                delegate?.provider(self, didCompleteWith: .inProgress, error: nil)
                didDismissWhilePending = true
            case .complete:
                debugLog("Apple pay sheet did finished at complete status")
                guard let confirmIntentResponse else {
                    assert(false, "should never happen")
                    delegate?.provider(self, didCompleteWith: .failure, error: nil)
                    return
                }
                switch confirmIntentResponse {
                case .success(let response):
                    complete(with: response, error: nil)
                case .failure(let error):
                    complete(with: nil, error: error)
                }
            }
        }
    }
}
