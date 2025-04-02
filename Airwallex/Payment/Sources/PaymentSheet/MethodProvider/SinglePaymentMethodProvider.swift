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
    
    var apiClient = AWXAPIClient(configuration: .shared())
    
    private var methodTypeDetails: AWXGetPaymentMethodTypeResponse?
    private var task: Task<AWXGetPaymentMethodTypeResponse, Error>?
    
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
        if name == AWXCardKey {
            let brands = supportedCardBrands ?? AWXCardBrand.all
            method.cardSchemes = brands.map { AWXCardScheme(name: $0.rawValue) }
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
                return try await apiClient.send(request) as! AWXGetPaymentMethodTypeResponse
            }
            self.task = task
            let response = try await task.value
            self.task = nil
            return response
        }
        return try await task.value
    }
}
