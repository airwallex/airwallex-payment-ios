//
//  PaymentMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Combine

enum PaymentMethodProviderUpdateType {
    case listUpdated
    case methodSelected(AWXPaymentMethodType)
    case consentDeleted(AWXPaymentConsent)
}

/// A protocol that defines a provider responsible for managing payment methods.
protocol PaymentMethodProvider: AnyObject {
    
    /// The API client used for making network requests.
    var apiClient: AWXAPIClient { get }
    
    /// The current payment session containing transaction details.
    var session: AWXSession { get }
    
    /// A publisher that sends updates related to payment methods and consents.
    var updatePublisher: PassthroughSubject<PaymentMethodProviderUpdateType, Never> { get }
    
    /// The currently selected payment method type.
    var selectedMethod: AWXPaymentMethodType? { get set }
    
    /// A list of available payment methods.
    var methods: [AWXPaymentMethodType] { get set }
    
    /// A list of available card payment consents.
    var consents: [AWXPaymentConsent] { get set }
    
    /// Fetches the available payment method types.
    /// - Throws: An error if the request fails.
    func getPaymentMethodTypes() async throws
}

extension PaymentMethodProvider {
    
    var isApplePayAvailable: Bool {
        return methods.contains { $0.name == AWXApplePayKey }
    }
    
    var applePayMethodType: AWXPaymentMethodType? {
        methods.first { $0.name == AWXApplePayKey }
    }
    
    func method(named name: String) -> AWXPaymentMethodType? {
        methods.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func consent(for identifier: String) -> AWXPaymentConsent? {
        consents.first { $0.id == identifier }
    }
    
    /// Revokes a payment consent.
    /// - Parameter consent: The payment consent to be disabled.
    func disable(consent: AWXPaymentConsent) async throws {
        let request = AWXDisablePaymentConsentRequest()
        request.requestId = UUID().uuidString
        request.id = consent.id
        try await apiClient.send(request)
        if let index = consents.firstIndex(where: { $0.id == consent.id }) {
            let deleted = consents.remove(at: index)
            updatePublisher.send(PaymentMethodProviderUpdateType.consentDeleted(deleted))
        }
    }
    
    /// Retrieves the payment method details for a payment method, typically used for LPM.
    /// - Parameter name: The name of the payment method (optional).
    /// - Returns: A response containing the payment method details, including a list of `AWXSchema` objects.
    func getPaymentMethodTypeDetails(name: String? = nil) async throws -> AWXGetPaymentMethodTypeResponse{
        guard let name = name ?? selectedMethod?.name else {
            throw ErrorMessage(rawValue:"Payment method name required")
        }
        let request = AWXGetPaymentMethodTypeRequest()
        request.name = name
        request.transactionMode = session.transactionMode()
        request.lang = session.lang
        return try await apiClient.send(request) as! AWXGetPaymentMethodTypeResponse
    }
    
    /// Retrieves a list of available banks for certain online banking payment methods that require bank selection.
    /// - Parameter name: The name of the payment method (optional).
    /// - Returns: A response containing the list of available banks.
    func getBankList(name: String? = nil) async throws -> AWXGetAvailableBanksResponse {
        guard let name = name ?? selectedMethod?.name else {
            throw ErrorMessage(rawValue:"Payment method name required")
        }
        let request = AWXGetAvailableBanksRequest()
        request.paymentMethodType = name
        request.countryCode = session.countryCode
        request.lang = session.lang
        let response = try await apiClient.send(request)
        return response as! AWXGetAvailableBanksResponse
    }
}
