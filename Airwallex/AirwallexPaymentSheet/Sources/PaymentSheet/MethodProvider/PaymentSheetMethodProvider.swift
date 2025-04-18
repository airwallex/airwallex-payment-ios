//
//  PaymentSheetMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine
#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Combine
#if canImport(AirwallexPayment)
@_spi(AWX) import AirwallexPayment
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
    var consents = [AWXPaymentConsent]()
    let apiClient: AWXAPIClient
    
    init(session: AWXSession,
         apiClient: AWXAPIClient = AWXAPIClient.init(configuration: .shared())) {
        self.session = session
        self.apiClient = apiClient
    }
    
    func getPaymentMethodTypes() async throws {
        async let methods = getAllMethodTypes()
        async let consents = getAllConsents()
        
        let availableMethods = try await methods.filter { methodType in
            guard !methodType.displayName.isEmpty,
                  let providerClass = ClassToHandleFlowForPaymentMethodType(methodType),
                  providerClass.canHandle(session, paymentMethod: methodType),
                  methodType.transactionMode == session.transactionMode() else {
                return false
            }
            
            if methodType.name == AWXWeChatPayKey, NSClassFromString("AWXWeChatPayActionProvider") == nil {
                // temporary solution - use AWXWeChatPayActionProvider to check if
                // payment(cocoapods)/AirwallexWeChatPay(SPM) is integrated
                return false
            }
            return true
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
            
        if filteredMethods.contains(where: { $0.name.lowercased() == AWXCardKey }) {
            //  filter consents
            set.removeAll()
            let filteredConsents = try await consents.filter { consent in
                guard consent.paymentMethod?.card?.brand != nil,
                      !set.contains(consent.id) else { return false }
                set.insert(consent.id)
                return true
            }
            
            self.consents = filteredConsents
        }
        selectedMethod = selectedMethod ?? filteredMethods.first { $0.name != AWXApplePayKey }
        updatePublisher.send(.listUpdated)
        guard !self.methods.isEmpty else {
            throw ErrorMessage(rawValue: NSLocalizedString("No payment methods available for this transaction.", bundle: .paymentSheet, comment: ""))
        }
    }
    
    func getPaymentMethodTypeDetails(name: String) async throws -> AWXGetPaymentMethodTypeResponse {
        let request = AWXGetPaymentMethodTypeRequest()
        request.name = name
        request.transactionMode = session.transactionMode()
        request.lang = session.lang
        return try await apiClient.send(request) as! AWXGetPaymentMethodTypeResponse
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
              let oneOffSession = session as? AWXOneOffSession,
              !oneOffSession.hidePaymentConsents else {
            return []
        }
        let request = AWXGetPaymentConsentsRequest()
        request.customerId = customerId
        request.status = "VERIFIED"
        request.nextTriggeredBy = FormatNextTriggerByType(AirwallexNextTriggerByType.customerType)
        request.pageNum = 0
        request.pageSize = 1000
        let response = try await apiClient.send(request) as! AWXGetPaymentConsentsResponse
        return response.items
    }
}
