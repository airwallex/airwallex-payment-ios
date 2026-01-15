//
//  MockMethodProvider.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
@testable import AirwallexPaymentSheet
import Combine
import Foundation

class MockMethodProvider: PaymentMethodProvider {
    func disable(consent: AWXPaymentConsent) async throws {
        consents.removeAll(where: { $0.id == consent.id })
    }
    
    var apiClient: AWXAPIClient = {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        let client = AWXAPIClient(configuration: clientConfiguration)
        return client
    }()
    
    var session: AWXSession = {
        let session = AWXOneOffSession()
        session.countryCode = "AU"
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.clientSecret = "client_secret"
        session.paymentIntent?.id = "intent_id"
        session.paymentIntent?.customerId = "customer_id"
        session.paymentIntent?.amount = NSDecimalNumber(value: 1)
        session.paymentIntent?.currency = "AUD"
        return session
    }()
    
    var updatePublisher = PassthroughSubject<PaymentMethodProviderUpdateType, Never>()
    
    var selectedMethod: AWXPaymentMethodType?
    
    var methods: [AWXPaymentMethodType]
    
    var consents: [AWXPaymentConsent]
    
    var mockSchemaDetails: AWXGetPaymentMethodTypeResponse?
    init(methods: [AWXPaymentMethodType], consents: [AWXPaymentConsent]) {
        self.methods = methods
        self.consents = consents
        self.selectedMethod = methods.first
    }
    
    var getPaymentMethodTypesError: Error?

    func getPaymentMethodTypes() async throws {
        if let error = getPaymentMethodTypesError {
            throw error
        }
        // Mock implementation - methods are already set via init
    }
    
    func getPaymentMethodTypeDetails(name: String) async throws -> AWXGetPaymentMethodTypeResponse {
        if let mockSchemaDetails {
            return mockSchemaDetails
        }
        fatalError()
    }
}
