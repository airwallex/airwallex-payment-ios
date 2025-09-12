//
//  PaymentSheetMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
import AirwallexCore
#endif
import Combine
import Foundation

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
    var consents = [AWXPaymentConsent]()
    let apiClient: AWXAPIClient
    
    /// fingerprint -> MIT consent object
    private var mitConsents = [String: AWXPaymentConsent]()
    
    init(session: AWXSession,
         apiClient: AWXAPIClient = AWXAPIClient.init(configuration: .shared())) {
        self.session = session
        self.apiClient = apiClient
    }
    
    func getPaymentMethodTypes() async throws {
        let methodsResult = try await getAllMethodTypes()
        methods = filterMethods(methodsResult)
        
        // Only fetch consents if AWXCardKey in the filtered methods
        if methods.contains(where: { $0.name.lowercased() == AWXCardKey }),
           (session is Session || session is AWXOneOffSession || session is AWXRecurringWithIntentSession) {
            // AWXOneOffSession and AWXRecurringWithIntentSession can be converted to Session internally to
            // work with the simplified consent flow
            let consentsResult = try await getAllConsents()
            let (filteredConsents, mitConsents) = filterConsents(consentsResult)
            consents = filteredConsents
            self.mitConsents = mitConsents
        } else {
            consents = [AWXPaymentConsent]()
            mitConsents = [String: AWXPaymentConsent]()
        }
        if let old = selectedMethod, let new = methods.first(where: { $0.name == old.name}) {
            selectedMethod = new
        } else {
            selectedMethod =  methods.first { $0.name != AWXApplePayKey }
        }
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
    
    func disable(consent: AWXPaymentConsent) async throws {
        let request = AWXDisablePaymentConsentRequest()
        request.id = consent.id
        try await apiClient.send(request)
        let result = removeConsent(consentId: consent.id)
        assert(result, "consent should exist until it is removed")
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
    
    func filterMethods(_ methods: [AWXPaymentMethodType]) -> [AWXPaymentMethodType] {
        
        let availableMethods = methods.filter { method in
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
        return filteredMethods
    }
    
    /// filter consents
    /// We will generally display consents in it's original order
    /// 1. When multiple MIT consents exist with the same fingerprint
    ///     keep the first one
    /// 2. when CIT and MIT consent with the same fingerprint exist
    /// display CIT cosent and keep MIT consent in mitConsents, when CIT consent removed, we should diplay MIT consent instead
    /// - Parameter consents: consents needs to be filtered
    /// - Returns: consents filtered and backup MIT consent
    func filterConsents(_ consents: [AWXPaymentConsent]) -> ([AWXPaymentConsent], [String: AWXPaymentConsent]) {
        var set = Set<String>()
        var mitConsents = [String: AWXPaymentConsent]()
        var filteredConsents = [AWXPaymentConsent]()
        let foo: [(String, AWXPaymentConsent)] = consents.compactMap { consent in
            guard let method = consent.paymentMethod,
                  method.type == AWXCardKey,
                  method.card != nil,
                  method.id != nil,
                  let fingerprint = method.card?.fingerprint else {
                return nil
            }
            if consent.isCITConsent {
                set.insert(fingerprint)
            }
            return (fingerprint, consent)
        }
        
        for (fingerprint, consent) in foo {
            if consent.isCITConsent {
                filteredConsents.append(consent)
            }
            if consent.isMITConsent {
                if !mitConsents.keys.contains(fingerprint) {
                    // no CIT or MIT with same fingerprint been displayed
                    if !set.contains(fingerprint) {
                        filteredConsents.append(consent)
                    }
                    mitConsents[fingerprint] = consent
                }
            }
        }
        return (filteredConsents, mitConsents)
    }
    
    func removeConsent(consentId: String) -> Bool {
        if let index = consents.firstIndex(where: { $0.id == consentId }) {
            let consent = consents.remove(at: index)
            if consent.isCITConsent {
                // when CIT consent removed, fallback to mit consent
                if let fingerprint = consent.paymentMethod?.card?.fingerprint,
                   let mitConsent = mitConsents[fingerprint] {
                    consents.insert(mitConsent, at: index)
                }
            }
            if consent.isMITConsent {
                // also remove MIT consent from mitConsents dictionary
                // we have blocked removal of MIT consent from payment UI,
                // so this will not actually happened
                if let element = mitConsents.first(where:{ $0.value.id == consentId }) {
                    mitConsents.removeValue(forKey: element.key)
                }
            }
            updatePublisher.send(PaymentMethodProviderUpdateType.consentDeleted(consent))
            return true
        }
        
        return false
    }
}
