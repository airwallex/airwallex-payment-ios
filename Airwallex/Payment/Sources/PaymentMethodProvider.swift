//
//  PaymentMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class PaymentMethodProvider {
    private let provider: AWXPaymentMethodListViewModel
    var session: AWXSession {
        provider.session
    }
    
    let publisher = PassthroughSubject<Void, Never>()
    var selectedMethod: AWXPaymentMethodType? {
        didSet {
            publisher.send()
        }
    }
    
    private(set) var methods = [AWXPaymentMethodType]()
    private(set) var consents = [AWXPaymentConsent]()
    
    init(provider: AWXPaymentMethodListViewModel) {
        self.provider = provider
    }
    
    var isApplePayAvailable: Bool {
        return methods.contains { $0.name == AWXApplePayKey }
    }
    
    func fetchPaymentMethods() async throws {
        let (methods, consents) = try await provider.fetchAvailablePaymentMethodsAndConsents()
        // even if there is no paymmentMethods defined in session, we still need to
        // make sure the payment methods and consents are unique
        let availableMethods = session.filteredPaymentMethodTypes(methods)
        var filteredConsents = [AWXPaymentConsent]()
        var methodDict = Dictionary(
            uniqueKeysWithValues: zip(
                availableMethods.map { $0.name.lowercased() },
                availableMethods
            )
        )
        // filter methods
        var set = Set<String>()
        var filteredMethods = [AWXPaymentMethodType]()
        if let predefinedMethods = session.paymentMethods, !predefinedMethods.isEmpty {
            for predefined in predefinedMethods.map({ $0.lowercased() }) {
                if let method = methodDict[predefined], !set.contains(predefined) {
                    filteredMethods.append(method)
                    set.insert(predefined)
                }
            }
        } else {
            for method in availableMethods {
                if set.contains(method.name) { continue }
                set.insert(method.name)
                filteredMethods.append(method)
            }
        }
        //  filter consents
        set.removeAll()
        filteredConsents = consents.filter { consent in
            guard consent.paymentMethod?.card?.brand != nil,
                  !set.contains(consent.id) else { return false }
            set.insert(consent.id)
            return true
        }
        
        self.methods = filteredMethods
        self.consents = filteredConsents
        publisher.send()
    }
    
    func method(named name: String) -> AWXPaymentMethodType? {
        methods.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func consent(for identifier: String) -> AWXPaymentConsent? {
        consents.first { $0.id == identifier }
    }
    
    func disable(consent: AWXPaymentConsent) async throws {
        let request = AWXDisablePaymentConsentRequest()
        request.requestId = UUID().uuidString
        request.id = consent.id
        let client = AWXAPIClient(configuration: .shared())
        try await client.send(request)
        if let index = consents.firstIndex(where: { $0.id == consent.id }) {
            consents.remove(at: index)
            publisher.send()
        }
    }
}

