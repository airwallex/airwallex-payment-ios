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
    
    var session: AWXSession = AWXOneOffSession()
    
    var updatePublisher = PassthroughSubject<PaymentMethodProviderUpdateType, Never>()
    
    var selectedMethod: AWXPaymentMethodType? = nil
    
    var methods: [AWXPaymentMethodType]
    
    var consents: [AWXPaymentConsent]
    
    init(methods: [AWXPaymentMethodType], consents: [AWXPaymentConsent]) {
        self.methods = methods
        self.consents = consents
        self.selectedMethod = methods.first
    }
    
    func getPaymentMethodTypes() async throws {
        fatalError()
    }
    
    func getPaymentMethodTypeDetails(name: String) async throws -> AWXGetPaymentMethodTypeResponse {
        fatalError()
    }
}
