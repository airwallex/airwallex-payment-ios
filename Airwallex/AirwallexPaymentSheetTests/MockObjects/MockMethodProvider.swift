//
//  MockMethodProvider.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
@testable import AirwallexPaymentSheet
@testable @_spi(AWX) import AirwallexPayment
import AirwallexCore
import Combine

class MockMethodProvider: PaymentMethodProvider {
    var apiClient: AWXAPIClient = {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        let client = AWXAPIClient(configuration: clientConfiguration)
        return client
    }()
    
    var session: AWXSession = {
        let session =  AWXOneOffSession()
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
    
    var selectedMethod: AWXPaymentMethodType? = nil
    
    var methods: [AWXPaymentMethodType]
    
    var consents: [AWXPaymentConsent]
    
    var mockSchemaDetails: AWXGetPaymentMethodTypeResponse?
    init(methods: [AWXPaymentMethodType], consents: [AWXPaymentConsent]) {
        self.methods = methods
        self.consents = consents
        self.selectedMethod = methods.first
    }
    
    func getPaymentMethodTypes() async throws {
        fatalError()
    }
    
    func getPaymentMethodTypeDetails(name: String) async throws -> AWXGetPaymentMethodTypeResponse {
        if let mockSchemaDetails {
            return mockSchemaDetails
        }
        fatalError()
    }
}
