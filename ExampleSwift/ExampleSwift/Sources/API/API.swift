//
//  API.swift
//  ExampleSwift
//
//  Created by Jarrod Robins on 15/5/2023.
//  Copyright © 2023 Airwallex. All rights reserved.
//

import Foundation

protocol API {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    func makeURLRequest(baseURL: URL, bearerToken: String?) -> URLRequest
}

enum HTTPMethod: String {
    case get
    case post
    case put
}

typealias HTTPStatusCode = Int
typealias HTTPStatusCodes = Range<HTTPStatusCode>

extension HTTPStatusCodes {
    static let success = 200 ..< 300
}

enum APIError: Error {
    case statusCode(HTTPStatusCode, errorBody: ErrorBody)
    case deserialization
}
