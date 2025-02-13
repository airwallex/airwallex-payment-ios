//
//  DirectAPIClient.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/10.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation
import Airwallex

class DirectAPIClient: APIClient {
    init() {
        let client = MockAPIClient.shared()
        client.apiKey = ExamplesKeys.apiKey;
        client.clientID = ExamplesKeys.clientId;
    }
    
    func createPaymentIntent(request: PaymentIntentRequest, completion: @escaping (Result<AWXPaymentIntent, Error>) -> Void) {
        MockAPIClient.shared().createAuthenticationToken { error in
            if let error {
                completion(.failure(error))
            } else {
                MockAPIClient.shared().createPaymentIntent(withParameters: request.dictionary) { intent, error in
                    if let intent {
                        completion(.success(intent))
                        return
                    }
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError.airwallexError(localizedMessage: "Failed to create payment intent")))
                    }
                }
            }
        }
    }
    
    func generateClientSecret(customerID: String, apiKey: String?, clientID: String?, completion: @escaping (Result<String, Error>) -> Void) {
        MockAPIClient.shared().createAuthenticationToken { error in
            if let error {
                completion(.failure(error))
            } else {
                MockAPIClient.shared().generateSecret(withCustomerId: customerID) { dict, error in
                    if let dict, let secret = dict["client_secret"] as? String {
                        completion(.success(secret))
                        return
                    }
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError.airwallexError(localizedMessage: "Failed to generate client secret")))
                    }
                }
            }
        }
    }
    
    func createCustomer(request: CustomerRequest, completion: @escaping (Result<Customer, any Error>) -> Void) {
        MockAPIClient.shared().createAuthenticationToken { error in
            if let error {
                completion(.failure(error))
            } else {
                MockAPIClient.shared().createCustomer(withParameters: request.dictionary) { dict, error in
                    if let dict, let customerID = dict["id"] as? String {
                        completion(.success(Customer(id: customerID)))
                        return
                    }
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError.airwallexError(localizedMessage: "Failed to create Customer")))
                    }
                }
            }
        }
    }
}

extension DirectAPIClient: CustomerFetchable {
    func createCustomer(firstName: String?, lastName: String?, email: String?, phoneNumber: String?, additionalInfo: Dictionary<String, Any>?, metadata: Dictionary<String, Int>, apiKey: String?, clientID: String?, completion: @escaping (Customer?, (any Error)?) -> Void) {
        createCustomer(request: CustomerRequest(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, additionalInfo: additionalInfo, metadata: metadata, apiKey: apiKey, clientID: clientID)) { result in
            switch (result) {
            case .success(let customer):
                completion(customer, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
