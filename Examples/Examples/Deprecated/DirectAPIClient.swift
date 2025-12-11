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
    
    init(apiKey: String?, clientID: String?) {
        let client = MockAPIClient.shared()
        client.apiKey = apiKey;
        client.clientID = clientID;
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

    func retrievePaymentIntent(_ intentId: String) async throws -> PaymentIntent {
        // Make async request
        let path = "api/v1/pa/payment_intents/\(intentId)"
        let requestURL = URL(string: path, relativeTo: MockAPIClient.shared().paymentBaseURL)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Airwallex-iOS-SDK", forHTTPHeaderField: "User-Agent")
        if let clientSecret = AWXAPIClientConfiguration.shared().clientSecret {
            request.setValue(clientSecret, forHTTPHeaderField: "client-secret")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // Check HTTP status code
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            // Try to extract error message from response
            if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = responseDict["message"] as? String {
                throw NSError(
                    domain: "com.airwallex.paymentacceptance",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
            }
            throw NSError.airwallexError(localizedMessage: "Invalid response from server")
        }

        // Decode using Decodable
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(PaymentIntent.self, from: data)
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
