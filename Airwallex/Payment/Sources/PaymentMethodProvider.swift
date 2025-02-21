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
    enum UpdateType {
        case listUpdated
        case methodSelected(AWXPaymentMethodType)
        case consentDeleted(AWXPaymentConsent)
    }
    
    let updatePublisher = PassthroughSubject<UpdateType, Never>()
    var selectedMethod: AWXPaymentMethodType? {
        didSet {
            if let selectedMethod {
                updatePublisher.send(.methodSelected(selectedMethod))
            }
        }
    }
    
    private(set) var methods = [AWXPaymentMethodType]()
    private(set) var consents = [AWXPaymentConsent]()
    private lazy var client = AWXAPIClient(configuration: .shared())
    
    init(provider: AWXPaymentMethodListViewModel) {
        self.provider = provider
    }
    
    var isApplePayAvailable: Bool {
        return methods.contains { $0.name == AWXApplePayKey }
    }
    
    var applePayMethodType: AWXPaymentMethodType? {
        methods.first { $0.name == AWXApplePayKey }
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
        selectedMethod = selectedMethod ?? filteredMethods.first { $0.name != AWXApplePayKey }
        updatePublisher.send(.listUpdated)
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
        try await client.send(request)
        if let index = consents.firstIndex(where: { $0.id == consent.id }) {
            let deleted = consents.remove(at: index)
            updatePublisher.send(.consentDeleted(deleted))
        }
    }
}

extension PaymentMethodProvider: SwiftLoggable {
    
    /// get payment method details for LPM
    /// - Parameter name: name of the method
    /// - Returns: details including a list of AWXSchema
    func getPaymentMethodTypeDetails(name: String? = nil) async throws -> (AWXGetPaymentMethodTypeResponse) {
        guard let selectedMethod else {
            throw ErrorMessage(rawValue:"No payment method selected")
        }
        let request = AWXGetPaymentMethodTypeRequest()
        request.name = name ?? selectedMethod.name
        request.transactionMode = session.transactionMode()
        request.lang = session.lang
        return try await client.send(request) as! AWXGetPaymentMethodTypeResponse
    }
    
    func getBankList() async throws -> AWXGetAvailableBanksResponse {
        guard let selectedMethod else {
            throw ErrorMessage(rawValue:"No payment method selected")
        }
        let request = AWXGetAvailableBanksRequest()
        request.paymentMethodType = selectedMethod.name
        request.countryCode = session.countryCode
        request.lang = session.lang
        let response = try await client.send(request)
        return response as! AWXGetAvailableBanksResponse
    }
}

