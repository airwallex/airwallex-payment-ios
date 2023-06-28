//
//  CartViewModel.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Combine
import Airwallex

@MainActor
class CartViewModel {
    
    private let repository: CartRepository
    
    private let environmentManager: EnvironmentManager
    private let networkManager: NetworkManager
    
    private(set) var shipping: Shipping = Fixtures.makeShipping()
    private(set) var products: [Product] = Fixtures.makeProducts()
    
    var customerID: String? {
        environmentManager.customerID
    }
    
    var environment: AirwallexSDKMode {
        environmentManager.environment
    }
    
    var formattedTotalAmount: String? {
        let total = products.reduce(Decimal(0)) { partialResult, product in
            partialResult + product.unitPrice
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: total as NSNumber)
    }
    
    init(
        environmentManager: EnvironmentManager = Dependencies.shared.environmentManager,
        networkManager: NetworkManager = Dependencies.shared.networkManager
    ) {
        self.environmentManager = environmentManager
        self.networkManager = networkManager
        
        self.repository = CartRepository(networkManager: networkManager)
    }
    
    func prepareForCheckOut() async throws -> AWXSession {
        guard
            let apiKey = environmentManager.apiKey,
            let clientID = environmentManager.clientID
        else {
            // no
            throw ExamplesError.missingRequiredConfigurationError
        }
        // 1: Authenticate with the Airwallex SDK
        try await authenticate(apiKey: apiKey, clientID: clientID)
        
        // 2: Create customer (if not already created)
        if environmentManager.customerID == nil {
            environmentManager.customerID = try await createCustomer()
        }
        
        if let customerID = environmentManager.customerID {
            // 3: Checkout
            return try await checkOut(customerID: customerID)
        } else {
            throw ExamplesError.missingCustomerIDError
        }
    }
    
    private func authenticate(apiKey: String, clientID: String) async throws {
        let result = try await repository.authenticate(
            apiKey: apiKey,
            clientID: clientID
        )
                
        environmentManager.authenticationToken = result
    }
    
    func createCustomer() async throws -> String {
        let request = CreateCustomerRequest(
            requestID: UUID().uuidString,
            merchantCustomerID: UUID().uuidString,
            firstName: shipping.firstName,
            lastName: shipping.lastName,
            email: shipping.email,
            phoneNumber: shipping.phoneNumber,
            additionalInfo: CreateCustomerRequestAdditionalInfo(
                isRegisteredViaSocialMedia: false,
                registrationDate: "2019-09-18",
                firstSuccessfulOrderDate: "2019-09-18"
            ),
            metadata: ["id": "1"]
        )
        
        let response = try await repository.createCustomer(request: request)
        return response.id
    }
    
    private func generateClientSecret(customerID: String) async throws -> String {
        do {
            let result = try await repository.generateClientSecret(customerID: customerID)
            return result.clientSecret
        } catch {
            throw ExamplesError.clientSecretError
        }
    }
    
    func createPaymentIntent(customerID: String) async throws -> AWXPaymentIntent {
        // Airwallex suggests performing this action on your own server
        // rather than implementing this logic in your app.
        let request = CreatePaymentIntentRequest(
            amount: "\(environmentManager.amount)",
            currency: environmentManager.currency,
            merchantOrderID: UUID().uuidString,
            requestID: UUID().uuidString,
            metadata: ["id": "1"],
            returnURL: environmentManager.returnURL ?? "",
            order: CreatePaymentIntentRequestOrder(
                products: products,
                shipping: shipping,
                type: "physical_goods"
            ),
            customerID: customerID
        )
        
        do {
            return try await repository.createPaymentIntent(request: request)
        } catch {
            throw ExamplesError.paymentIntentError
        }
    }
    
    private func checkOut(customerID: String) async throws -> AWXSession {
        let checkoutMode = environmentManager.checkoutMode
        
        switch checkoutMode {
        case .oneOff, .recurringWithIntent:
            let paymentIntent = try await createPaymentIntent(customerID: customerID)
            
            // for one-off and recurring with intent checkout modes,
            // use the client secret from the payment intent.
            AWXAPIClientConfiguration.shared().clientSecret = paymentIntent.clientSecret
            
            return makeSession(
                checkoutMode: checkoutMode,
                customerID: customerID,
                intent: paymentIntent
            )
        case .recurring:
            // for recurring payments, generate a client secret.
            // Airwallex suggests performing this action on your own server
            // rather than implementing this logic in your app.
            let clientSecret = try await generateClientSecret(customerID: customerID)
            
            AWXAPIClientConfiguration.shared().clientSecret = clientSecret
            
            return makeSession(
                checkoutMode: checkoutMode,
                customerID: customerID,
                intent: nil
            )
        }
    }
    
    private func makeSession(
        checkoutMode: AirwallexCheckoutMode,
        customerID: String,
        intent: AWXPaymentIntent?
    ) -> AWXSession {
        switch checkoutMode {
        case .oneOff:
            return makeOneOffSession(intent: intent)
        case .recurring:
            return makeRecurringSession(customerID: customerID)
        case .recurringWithIntent:
            return makeRecurringSessionWithIntent(intent: intent)
        }
    }
    
    private func makeOneOffSession(intent: AWXPaymentIntent?) -> AWXOneOffSession {
        // from user defaults
        let countryCode: String = environmentManager.countryCode
        let returnURL: String = environmentManager.returnURL ?? ""
        let autoCapture: Bool = environmentManager.isAutocaptureEnabled
        let merchantIdentifier: String = "merchant.com.airwallex.paymentacceptance"
        
        // continue
        let session = AWXOneOffSession()
        let applePayOptions = AWXApplePayOptions(
            merchantIdentifier: merchantIdentifier
        )
        applePayOptions.additionalPaymentSummaryItems = [
            PKPaymentSummaryItem(label: "goods", amount: 2),
            PKPaymentSummaryItem(label: "tax", amount: 1)
        ]
        applePayOptions.requiredBillingContactFields = [.postalAddress]
        applePayOptions.totalPriceLabel = "COMPANY, INC."
        
        session.applePayOptions = applePayOptions
        session.countryCode = countryCode
        session.billing = shipping.asAWXPlaceDetails()
        session.returnURL = returnURL
        
        // payment intent will only be available for one off and recurring with intent
        session.paymentIntent = intent
        session.autoCapture = autoCapture
        return session
    }
    
    private func makeRecurringSession(customerID: String) -> AWXRecurringSession {
        // user defaults
        let countryCode: String = environmentManager.countryCode
        let returnURL: String = environmentManager.returnURL ?? ""
        let currency = environmentManager.currency
        let amount: NSDecimalNumber = environmentManager.amount as NSDecimalNumber
        let nextTriggerByType: AirwallexNextTriggerByType = environmentManager.nextTriggerBy
        let requiresCVC: Bool = environmentManager.isRequiresCVCEnabled
        let merchantTriggerReason = AirwallexMerchantTriggerReason.unscheduled
        
        // continue
        let session = AWXRecurringSession()
        session.countryCode = countryCode
        session.billing = shipping.asAWXPlaceDetails()
        session.returnURL = returnURL
        session.setCurrency(currency)
        session.setAmount(amount)
        session.setCustomerId(customerID)
        session.nextTriggerByType = nextTriggerByType
        session.setRequiresCVC(requiresCVC)
        session.merchantTriggerReason = merchantTriggerReason
        return session
    }
    
    private func makeRecurringSessionWithIntent(intent: AWXPaymentIntent?) -> AWXRecurringWithIntentSession {
        // user defaults
        let countryCode: String = environmentManager.countryCode
        let returnURL: String = environmentManager.returnURL ?? ""
        let nextTriggerByType: AirwallexNextTriggerByType = environmentManager.nextTriggerBy
        let requiresCVC: Bool = environmentManager.isRequiresCVCEnabled
        let autoCapture: Bool = environmentManager.isAutocaptureEnabled
        let merchantTriggerReason = AirwallexMerchantTriggerReason.scheduled
        
        let session = AWXRecurringWithIntentSession()
        session.countryCode = countryCode
        session.billing = shipping.asAWXPlaceDetails()
        session.returnURL = returnURL
        session.paymentIntent = intent
        session.nextTriggerByType = nextTriggerByType
        session.setRequiresCVC(requiresCVC)
        session.autoCapture = autoCapture
        session.merchantTriggerReason = merchantTriggerReason
        return session
    }
}
