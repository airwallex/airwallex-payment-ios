//
//  SinglePaymentMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import Combine
#if canImport(Core)
import Core
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
    
    let apiClient = AWXAPIClient(configuration: AWXAPIClientConfiguration.shared())
    
    private var methodTypeDetails: AWXGetPaymentMethodTypeResponse?
    
    func getPaymentMethodTypes() async throws {
        let response = try await getPaymentMethodTypeDetails(name: name)
        methodTypeDetails = response
        
        guard response.name == AWXCardKey || response.name == AWXApplePayKey || response.hasSchema else {
            throw NSLocalizedString("Invalid payment method", bundle: .payment, comment: "").asError()
        }
        
        let resources = AWXResources()
        resources.logoURL = response.logoURL
        resources.hasSchema = response.hasSchema
        
        let method = AWXPaymentMethodType()
        method.name = response.name
        method.displayName = response.displayName
        method.resources = resources
        method.transactionMode = session.transactionMode()
        if name == AWXCardKey, let brands = supportedCardBrands, !brands.isEmpty {
            method.cardSchemes = brands.map { brand in
                let scheme = AWXCardScheme()
                scheme.name = brand.rawValue
                return scheme
            }
        }
        methods = [method]
        selectedMethod = method
        updatePublisher.send(.listUpdated)
    }
    
    /// Override default implementation in protocol extension
    /// - Parameter name: name of the payment method
    /// - Returns: Details (schema) of the payment method
    func getPaymentMethodTypeDetails(name: String? = nil) async throws -> AWXGetPaymentMethodTypeResponse {
        if let methodTypeDetails, name == self.name {
            return methodTypeDetails
        }
        let request = AWXGetPaymentMethodTypeRequest()
        request.name = name ?? self.name
        request.transactionMode = session.transactionMode()
        request.lang = session.lang
        return try await apiClient.send(request) as! AWXGetPaymentMethodTypeResponse
    }
}
