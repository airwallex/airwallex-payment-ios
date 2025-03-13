//
//  PaymentSheetMethodProvider.swift
//  Airwallex
//
//  Created by Weiping Li on 2024/12/12.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Combine

final class PaymentSheetMethodProvider: PaymentMethodProvider, DebugLoggable {
    
    private let provider: AWXPaymentMethodListViewModel
    var session: AWXSession {
        provider.session
    }
    
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
    let apiClient = AWXAPIClient(configuration: .shared())
    
    init(session: AWXSession) {
        provider = AWXPaymentMethodListViewModel(
            session: session,
            apiClient: apiClient
        )
    }
    
    func getPaymentMethodTypes() async throws {
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
        //  fps (webqr) is not supported for now
        filteredMethods = filteredMethods.filter { $0.name != "fps"}
        
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
        guard !self.methods.isEmpty else {
            throw ErrorMessage(rawValue: NSLocalizedString("No payment methods available for this transaction.", bundle: .payment, comment: ""))
        }
    }
}
