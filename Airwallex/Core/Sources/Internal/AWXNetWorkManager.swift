//
//  AWXNetWorkManager.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

@objcMembers
@objc
public class AWXNetWorkManager: NSObject {
    public static let shared = AWXNetWorkManager()
    public var session = URLSession.shared
    public var baseURL: String {
        switch Airwallex.mode() {
        case .demoMode:
            "https://api-demo.airwallex.com/"
        case .productionMode:
            "https://api.airwallex.com/"
        case .stagingMode:
            "https://api-staging.airwallex.com/"
        @unknown default:
            ""
        }
    }

    private let headers = [
        "Content-Type": "application/json",
        "x-api-version": AIRWALLEX_API_VERSION,
        "User-Agent": "Airwallex-iOS-SDK",
    ]

    override private init() {}
    func performRequest<T: Codable>(
        urlString: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: baseURL + urlString)
        var queryItems = [URLQueryItem]()

        var request: URLRequest
        if method == .GET {
            if let parameters = parameters as? [String: String] {
                for (key, value) in parameters {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            urlComponents?.queryItems = queryItems
            guard let url = urlComponents?.url else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: AWXSDKErrorDomain, code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "badURL.Please check your URL."]
                            )))
                }
                return
            }
            request = URLRequest(url: url)
        } else if method == .POST {
            guard let url = URL(string: baseURL + urlString) else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: AWXSDKErrorDomain, code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "badURL.Please check your URL."]
                            )))
                }
                return
            }
            request = URLRequest(url: url)
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters ?? [:], options: [])
        } else {
            guard let url = URL(string: baseURL + urlString) else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: AWXSDKErrorDomain, code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "badURL.Please check your URL."]
                            )))
                }
                return
            }
            request = URLRequest(url: url)
        }

        request.httpMethod = method.rawValue

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let clientSecret = AWXAPIClientConfiguration.shared().clientSecret {
            request.setValue(clientSecret, forHTTPHeaderField: "client-secret")
        }

        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: AWXSDKErrorDomain, code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No data."]
                            )))
                }
                return
            }

            if let error = T.parseError(data) {
                DispatchQueue.main.async {
                    completion(.failure(NSError(
                        domain: AWXSDKErrorDomain, code: -1,
                        userInfo: [NSLocalizedDescriptionKey: error.message]
                    )))
                }
                return
            }

            if let decodedData = T.from(data) {
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: AWXSDKErrorDomain, code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Fail to decode data."]
                            )))
                }
            }
        }
        task.resume()
    }

    public func get<T: Codable>(
        urlString: String,
        parameters: [String: String]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        performRequest(
            urlString: urlString, method: .GET, parameters: parameters, completion: completion
        )
    }

    public func post<T: Codable>(
        urlString: String,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        performRequest(
            urlString: urlString, method: .POST, parameters: parameters, completion: completion
        )
    }
}
