//
//  PaymentMethodFetcher.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/2/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

@objc protocol PaymentMethodFetcher {
    var session: AWXSession { get }
    func fetchAvailablePaymentMethodsAndConsents() async throws -> ([AWXPaymentMethodType], [AWXPaymentConsent])
}

extension AWXPaymentMethodListViewModel: PaymentMethodFetcher {}

class PresetPaymentMethodProvider: PaymentMethodFetcher {
    let session: AWXSession
    
    let paymentMethods: [AWXPaymentMethodType]
    let paymentConsents: [AWXPaymentConsent]
    
    init(session: AWXSession, paymentMethods: [AWXPaymentMethodType], consents: [AWXPaymentConsent] = []) {
        self.session = session
        self.paymentMethods = paymentMethods
        self.paymentConsents = consents
    }
    
    func fetchAvailablePaymentMethodsAndConsents() async throws -> ([AWXPaymentMethodType], [AWXPaymentConsent]) {
        (paymentMethods, paymentConsents)
    }
}
