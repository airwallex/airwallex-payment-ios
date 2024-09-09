//
//  APIClient.swift
//  Examples
//
//  Created by Hector.Huang on 2024/9/5.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Airwallex

protocol APIClient {
    func createPaymentIntent(request: PaymentIntentRequest, completion: @escaping (Result<AWXPaymentIntent, Error>) -> Void)
    
    func generateClientSecret(customerID: String, apiKey: String?, clientID: String?, completion: @escaping (Result<String, Error>) -> Void)
    
    func createCustomer(request: CustomerRequest, completion: @escaping (Result<Customer, Error>) -> Void)
}

@objc protocol CustomerFetchable {
    func createCustomer(
        firstName: String?,
        lastName: String?,
        email: String?,
        phoneNumber: String?,
        additionalInfo: Dictionary<String, Any>?,
        metadata: Dictionary<String, Int>,
        apiKey: String?,
        clientID: String?,
        completion: @escaping (Customer?, Error?) -> Void
    )
}


class DemoStoreAPIClient: APIClient, CustomerFetchable {
    private var demoStoreBaseUrl: String? {
        switch Airwallex.mode() {
        case .demoMode:
            "https://demo-pacheckoutdemo.airwallex.com"
        case .stagingMode:
            "https://staging-pacheckoutdemo.airwallex.com"
        case .productionMode:
            nil
        }
    }
    
    func createPaymentIntent(request: PaymentIntentRequest, completion: @escaping (Result<AWXPaymentIntent, Error>) -> Void) {
        post(path: "/api/v1/pa/payment_intents/create", encodable: request, completion: completion)
    }
    
    func createCustomer(request: CustomerRequest, completion: @escaping (Result<Customer, Error>) -> Void) {
        post(path: "/api/v1/pa/customers/create", encodable: request, completion: completion)
    }
    
    func createCustomer(firstName: String?, lastName: String?, email: String?, phoneNumber: String?, additionalInfo: Dictionary<String, Any>?, metadata: Dictionary<String, Int>, apiKey: String?, clientID: String?, completion: @escaping (Customer?, Error?) -> Void) {
        createCustomer(request: CustomerRequest(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, additionalInfo: additionalInfo, metadata: metadata, apiKey: apiKey, clientID: clientID)) { result in
            switch (result) {
            case .success(let customer):
                completion(customer, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func generateClientSecret(customerID: String, apiKey: String?, clientID: String?, completion: @escaping (Result<String, any Error>) -> Void) {
        guard let baseUrl = demoStoreBaseUrl, var urlComponents = URLComponents(string: baseUrl + "/api/v1/pa/customers/\(customerID)/generate_client_secret") else {
            preconditionFailure("Unable to build URL components")
        }
        var queryItems = [URLQueryItem]()
        if let apiKey {
            queryItems.append(.init(name: "apiKey", value: apiKey))
        }
        if let clientID {
            queryItems.append(.init(name: "clientId", value: clientID))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            preconditionFailure("Unable to unwrap URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data {
                let responseDict: [String: Any]?
                do {
                    responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                } catch {
                    completion(.failure(error))
                    return
                }
                
                if let errorMessage = responseDict?["message"] as? String {
                    completion(.failure(NSError.airwallexError(localizedMessage: errorMessage)))
                    return
                }
                if let clientSecret = (responseDict as? [String: String])?["client_secret"] {
                    completion(.success(clientSecret))
                } else {
                    completion(.failure(NSError.airwallexError(localizedMessage: "Failed to decode to client secret")))
                }
            }
        }.resume()
    }
    
    private func post<T: AWXJSONDecodable>(path: String, encodable: Encodable, completion: @escaping (Result<T, Error>) -> Void) {
        guard let baseUrl = demoStoreBaseUrl, let url = URL(string: baseUrl + path) else {
            preconditionFailure("Unable to unwrap URL")
        }
        guard let body = try? JSONEncoder().encode(encodable) else {
            preconditionFailure("Unable to serialize JSON")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }
            if let data {
                let responseDict: [String: Any]?
                do {
                    responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                } catch {
                    completion(.failure(error))
                    return
                }
                
                if let errorMessage = responseDict?["message"] as? String {
                    completion(.failure(NSError.airwallexError(localizedMessage: errorMessage)))
                } else {
                    if let model = T.decode(fromJSON: responseDict) as? T {
                        completion(.success(model))
                    } else {
                        completion(.failure(NSError.airwallexError(localizedMessage: "Failed to decode to \(String(describing: T.self))")))
                    }
                }
            }
        }.resume()
    }
}
