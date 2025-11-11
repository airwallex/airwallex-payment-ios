//
//  SinglePaymentMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

class SinglePaymentMethodProvider: PaymentMethodProvider {
    
    let name: String
    private var supportedCardBrands: [AWXCardBrand]?
    
    init(session: AWXSession,
         name: String,
         supportedCardBrands: [AWXCardBrand]? = nil) {
        self.session = session
        self.name = name
        self.supportedCardBrands = supportedCardBrands
    }
    
    // MARK: - PaymentMethodProvider
    let updatePublisher = PassthroughSubject<PaymentMethodProviderUpdateType, Never>()
    
    var selectedMethod: AWXPaymentMethodType? {
        didSet {
            if let selectedMethod {
                updatePublisher.send(.methodSelected(selectedMethod))
            }
        }
    }
    
    var methods = [AWXPaymentMethodType]()
    
    var consents = [AWXPaymentConsent]()
    
    let session: AWXSession
    
    var apiClient = AWXAPIClient(configuration: .shared())
    
    private var methodTypeDetails: AWXGetPaymentMethodTypeResponse?
    private var task: Task<AWXGetPaymentMethodTypeResponse, Error>?
    
    func getPaymentMethodTypes() async throws {
        let method = AWXPaymentMethodType()
        method.name = name
        method.transactionMode = session.transactionMode()
        method.resources = AWXResources()
        switch name {
        case AWXApplePayKey:
            method.displayName = NSLocalizedString("Apple Pay", bundle: .paymentSheet, comment: "")
        case AWXCardKey:
            method.displayName = NSLocalizedString("Card", bundle: .paymentSheet, comment: "")
            let brands = supportedCardBrands ?? AWXCardBrand.allAvailable
            method.cardSchemes = brands.map { AWXCardScheme(name: $0.rawValue) }
        default:
            let response = try await getPaymentMethodTypeDetails(name: name)
            guard response.hasSchema else {
                throw "Invalid payment method".asError()
            }
            methodTypeDetails = response
            method.displayName = response.displayName
            method.resources.logoURL = response.logoURL
            method.resources.hasSchema = response.hasSchema
        }
        methods = [method]
        selectedMethod = method
        updatePublisher.send(.listUpdated)
    }
    
    func getPaymentMethodTypeDetails(name: String) async throws -> AWXGetPaymentMethodTypeResponse {
        if let methodTypeDetails, name == self.name {
            return methodTypeDetails
        }
        guard let task, !task.isCancelled else {
            let request = AWXGetPaymentMethodTypeRequest()
            request.name = name
            request.transactionMode = session.transactionMode()
            request.lang = session.lang
            let task = Task {
                try await (session as? Session)?.ensurePaymentIntent()
                return try await apiClient.send(request) as! AWXGetPaymentMethodTypeResponse
            }
            self.task = task
            let response = try await task.value
            self.task = nil
            return response
        }
        return try await task.value
    }
    
    func disable(consent: AWXPaymentConsent) async throws {}
}
