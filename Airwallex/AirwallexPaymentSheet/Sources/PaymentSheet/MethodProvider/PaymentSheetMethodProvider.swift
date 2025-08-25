//
//  PaymentSheetMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif

final class PaymentSheetMethodProvider: PaymentMethodProvider {
    
    let session: AWXSession
    let updatePublisher = PassthroughSubject<PaymentMethodProviderUpdateType, Never>()
    var selectedMethod: AWXPaymentMethodType? {
        didSet {
            if let selectedMethod {
                updatePublisher.send(.methodSelected(selectedMethod))
            }
        }
    }
    
    var methods = [AWXPaymentMethodType]()
    var consents: [AWXPaymentConsent] {
        var set = Set<String>()
        return (citConsents + mitConsents).reduce(into: [AWXPaymentConsent]()) { partialResult, consent in
            guard let methodId = consent.paymentMethod?.id else { return }
            if !set.contains(methodId) {
                partialResult.append(consent)
                set.insert(methodId)
            }
        }
    }
    let apiClient: AWXAPIClient
    
    private var mitConsents = [AWXPaymentConsent]()
    private var citConsents = [AWXPaymentConsent]()
    
    init(session: AWXSession,
         apiClient: AWXAPIClient = AWXAPIClient.init(configuration: .shared())) {
        self.session = session
        self.apiClient = apiClient
    }
    
    func getPaymentMethodTypes() async throws {
        let methodsResult = try await getAllMethodTypes()
        
        let availableMethods = methodsResult.filter { method in
            PaymentSessionHandler.canHandle(methodType: method, session: session)
        }
        
        // even if there is no paymmentMethods defined in session, we still need to
        // make sure the payment methods and consents are unique
        let methodDict = Dictionary(
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
        self.methods = filteredMethods
        
        // Only fetch consents if AWXCardKey in the filtered methods
        citConsents.removeAll()
        mitConsents.removeAll()
        if filteredMethods.contains(where: { $0.name.lowercased() == AWXCardKey }) {
            let consentsResult = try await getAllConsents()
            //  filter consents
            set.removeAll()
            var citSet = Set<String>()
            var mitSet = Set<String>()
            for consent in consentsResult {
                guard let method = consent.paymentMethod,
                      method.type == AWXCardKey,
                      method.card != nil,
                      let methodId = method.id else {
                    continue
                }
                switch consent.nextTriggeredBy {
                case FormatNextTriggerByType(.customerType):
                    if !citSet.contains(consent.id) {
                        citSet.insert(consent.id)
                        citConsents.append(consent)
                    }
                case FormatNextTriggerByType(.merchantType):
                    if !mitSet.contains(methodId) {
                        mitSet.insert(methodId)
                        mitConsents.append(consent)
                    }
                default:
                    break
                }
            }
        }
        selectedMethod = selectedMethod ?? filteredMethods.first { $0.name != AWXApplePayKey }
        updatePublisher.send(.listUpdated)
        guard !self.methods.isEmpty else {
            throw ErrorMessage(rawValue: "No payment methods available for this transaction.")
        }
    }
    
    func getPaymentMethodTypeDetails(name: String) async throws -> AWXGetPaymentMethodTypeResponse {
        let request = AWXGetPaymentMethodTypeRequest()
        request.name = name
        request.transactionMode = session.transactionMode()
        request.lang = session.lang
        return try await apiClient.send(request) as! AWXGetPaymentMethodTypeResponse
    }
    
    func removeConsent(consentId: String) -> Bool {
        if let index = citConsents.firstIndex(where: { $0.id == consentId }) {
            citConsents.remove(at: index)
            return true
        }
        if let index = mitConsents.firstIndex(where: { $0.id == consentId }) {
            mitConsents.remove(at: index)
            return true
        }
        return false
    }
}

private extension PaymentSheetMethodProvider {
    
    func getAllMethodTypes() async throws -> [AWXPaymentMethodType] {
        let request = AWXGetPaymentMethodTypesRequest()
        request.transactionCurrency = session.currency()
        request.transactionMode = session.transactionMode()
        request.countryCode = session.countryCode
        request.lang = session.lang
        request.pageNum = 0
        request.pageSize = 1000
        request.flow = AWXPaymentMethodFlow.app.rawValue
        let response = try await apiClient.send(request) as! AWXGetPaymentMethodTypesResponse
        return response.items
    }
    
    func getAllConsents() async throws -> [AWXPaymentConsent] {
        guard let customerId = session.customerId(),
              !session.hidePaymentConsents else {
            return []
        }
        
        if let predefinedMethods = session.paymentMethods {
            guard predefinedMethods.contains(where: { $0.lowercased() == AWXCardKey }) else {
                return []
            }
        }
        let request = AWXGetPaymentConsentsRequest()
        request.customerId = customerId
        request.status = "VERIFIED"
        request.pageNum = 0
        request.pageSize = 1000
        let response = try await apiClient.send(request) as! AWXGetPaymentConsentsResponse
        return response.items
    }
}
