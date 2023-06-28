//
//  ExamplesAPI.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

enum ExamplesAPI {
    case createAuthenticationToken(clientID: String, apiKey: String)
    case createCustomer(request: CreateCustomerRequest)
    case generateClientSecret(customerID: String)
    case createPaymentIntent(request: CreatePaymentIntentRequest)
}

extension ExamplesAPI: API {
    var path: String {
        switch self {
        case .createAuthenticationToken:
            return "api/v1/authentication/login"
        case .createCustomer:
            return "api/v1/pa/customers/create"
        case .generateClientSecret(let customerID):
            return "api/v1/pa/customers/\(customerID)/generate_client_secret"
        case .createPaymentIntent:
            return "api/v1/pa/payment_intents/create"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createAuthenticationToken:
            return .post
        case .createCustomer:
            return .post
        case .generateClientSecret:
            return .get
        case .createPaymentIntent:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .createCustomer(let request):
            let encoder = JSONEncoder()
            return try? encoder.encode(request)
        case .createPaymentIntent(let request):
            let encoder = JSONEncoder()
            return try? encoder.encode(request)
        default:
            return nil
        }
    }

    var headers: [String : String] {
        let baseHeaders: [String: String] = [
            "Content-Type": "application/json",
            "User-Agent": "Airwallex-iOS-SDK"
        ]
        
        switch self {
        case .createAuthenticationToken(let clientID, let apiKey):
            let headers = [
                "x-client-id": clientID,
                "x-api-key": apiKey
            ]
            return baseHeaders.merging(headers) { _, new in new }
        case .createCustomer:
            let headers: [String: String] = [:]
            return baseHeaders.merging(headers) { _, new in new }
        case .generateClientSecret:
            let headers: [String: String] = [:]
            return baseHeaders.merging(headers) { _, new in new }
        case .createPaymentIntent:
            let headers: [String: String] = [:]
            return baseHeaders.merging(headers) { _, new in new }
        }
    }
    
    func makeURLRequest(
        baseURL: URL,
        bearerToken: String?
    ) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = body
        return request
    }
}
