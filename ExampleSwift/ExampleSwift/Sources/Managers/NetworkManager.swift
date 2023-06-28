//
//  NetworkManager.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation
import Combine
import Airwallex

struct NetworkManager {

    // MARK: - Properties

    private let urlSession: URLSession
    private let environmentManager: EnvironmentManager

    // MARK: - Initializer

    init(urlSession: URLSession, environmentManager: EnvironmentManager) {
        self.urlSession = urlSession
        self.environmentManager = environmentManager
    }

    // MARK: - NetworkService
    
    func performRequest(with api: API) async throws -> Data {
        let url = Airwallex.defaultBaseURL()
    
        // TODO: handle expired token?
        let request = api.makeURLRequest(
            baseURL: url,
            bearerToken: environmentManager.authenticationToken?.token
        )

        assert(!Thread.isMainThread)
        
        let (data, response) = try await urlSession.data(for: request)
        
        // Check to see we received a reasonable response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.deserialization
        }
        
        // Check that the response is in the 200 OK range
        guard HTTPStatusCodes.success.contains(httpResponse.statusCode) else {
            let decoder = JSONDecoder()
            let errorBody = try decoder.decode(ErrorBody.self, from: data)
            
            throw APIError.statusCode(httpResponse.statusCode, errorBody: errorBody)
        }
        
        return data
    }
}

