//
//  MockMethodProvider.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
@testable import AirwallexPaymentSheet
import AirwallexCore
import Combine

class MockMethodProvider: PaymentMethodProvider {
    var apiClient = AWXAPIClient(configuration: .shared())
    
    var session: AWXSession = {
        let session =  AWXOneOffSession()
        session.paymentIntent = AWXPaymentIntent()
        session.paymentIntent?.clientSecret = "client_secret"
        session.paymentIntent?.id = "intent_id"
        session.paymentIntent?.customerId = "customer_id"
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
