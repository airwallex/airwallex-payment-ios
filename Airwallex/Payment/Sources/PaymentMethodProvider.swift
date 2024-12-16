//
//  PaymentMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@MainActor
final class PaymentMethodProvider {
    private let provider: AWXPaymentMethodListViewModel
    enum Foo: String {
        case one
    }
    var session: AWXSession {
        provider.session
    }
    
    private(set) var methods = [AWXPaymentMethodType]()
    private(set) var consents = [AWXPaymentConsent]()
    
    init(provider: AWXPaymentMethodListViewModel) {
        self.provider = provider
    }
    
    var isApplePayAvailable: Bool {
        guard let applePay = methods.first(where: { $0.name == AWXApplePayKey }) else {
            return false
        }
        return true
    }
    
    func fetchPaymentMethods() async throws {
        let (methods, consents) = try await provider.fetchAvailablePaymentMethodsAndConsents()
        let availableMethods = session.filteredPaymentMethodTypes(methods)
        if let predefinedMethods = session.paymentMethods, !predefinedMethods.isEmpty {
            var tempMethods = [AWXPaymentMethodType]()
            var tempConsents = [AWXPaymentConsent]()
            for predefined in predefinedMethods {
                for available in availableMethods {
                    if predefined.lowercased() == available.name.lowercased() && !tempMethods.contains(available) {
                        tempMethods.append(available)
                        break
                     }
                }
                for available in consents {
                    guard let type = available.paymentMethod?.type.lowercased() else { continue }
                    if predefined.lowercased() == type {
                        tempConsents.append(available)
                        break
                    }
                }
            }
            self.methods = tempMethods
            self.consents = consents
        } else {
            self.methods = methods
            self.consents = consents
        }
    }
    
    func method(named name: String) -> AWXPaymentMethodType? {
        methods.first { $0.name == name }
    }
}

