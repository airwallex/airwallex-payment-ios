//
//  CartRepository.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 26/6/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Airwallex


class CartRepository {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = Dependencies.shared.networkManager) {
        self.networkManager = networkManager
    }
    
    func authenticate(apiKey: String, clientID: String) async throws -> AuthenticationToken {
        do {
            let data = try await networkManager.performRequest(
                with: ExamplesAPI.createAuthenticationToken(
                    clientID: clientID,
                    apiKey: apiKey
                )
            )
            let decoder = JSONDecoder()
            let result = try decoder.decode(AuthenticationToken.self, from: data)
            return result
        } catch APIError.statusCode(_, let errorBody) {
            throw ExamplesError.apiError(
                title: NSLocalizedString("Authentication Error", comment: ""),
                message: errorBody.message
            )
        } catch let e {
            throw e
        }
    }
    
    func createCustomer(request: CreateCustomerRequest) async throws -> CreateCustomerResponse {
        do {
            let data = try await networkManager.performRequest(
                with: ExamplesAPI.createCustomer(request: request)
            )
            let decoder = JSONDecoder()
            let result = try decoder.decode(CreateCustomerResponse.self, from: data)
            return result
        } catch APIError.statusCode(_, let errorBody) {
            throw ExamplesError.apiError(
                title: NSLocalizedString("Create Customer Error", comment: ""),
                message: errorBody.message
            )
        } catch let e {
            throw e
        }
    }
    
    func generateClientSecret(customerID: String) async throws -> GenerateClientSecretResponse {
        do {
            let data = try await networkManager.performRequest(
                with: ExamplesAPI.generateClientSecret(customerID: customerID)
            )
            let decoder = JSONDecoder()
            let result = try decoder.decode(GenerateClientSecretResponse.self, from: data)
            return result
        } catch APIError.statusCode(_, let errorBody) {
            throw ExamplesError.apiError(
                title: NSLocalizedString("Generate Client Secret Error", comment: ""),
                message: errorBody.message
            )
        } catch let e {
            throw e
        }
    }
    
    func createPaymentIntent(request: CreatePaymentIntentRequest) async throws -> AWXPaymentIntent {
        do {
            let data = try await networkManager.performRequest(
                with: ExamplesAPI.createPaymentIntent(request: request)
            )
            
            guard let paymentIntent = AWXPaymentIntent.decode(fromJSONData: data) else {
                throw ExamplesError.paymentIntentError
            }
            return paymentIntent
        } catch APIError.statusCode(_, let errorBody) {
            throw ExamplesError.apiError(
                title: NSLocalizedString("Create Payment Intent Error", comment: ""),
                message: errorBody.message
            )
        } catch let e {
            throw e
        }
    }
}
