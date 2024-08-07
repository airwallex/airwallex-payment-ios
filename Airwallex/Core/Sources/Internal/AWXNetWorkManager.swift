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
    init(session: URLSession = URLSession.shared) {
        self.session = session
        super.init()
    }

    public let session: URLSession
    public var baseURL: String {
        switch Airwallex.mode() {
        case .demoMode:
            "https://api-demo.airwallex.com/"
        case .productionMode:
            "https://api.airwallex.com/"
        case .stagingMode:
            "https://api-staging.airwallex.com/"
        }
    }

    private let headers = [
        "Content-Type": "application/json",
        "x-api-version": AIRWALLEX_API_VERSION,
        "User-Agent": "Airwallex-iOS-SDK",
    ]

    private func performRequest<T: Decodable>(
        path: String,
        method: HTTPMethod = .GET,
        parameters: [String: String]? = nil,
        payload: Data? = nil,
        eventName: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request: URLRequest
        if method == .GET {
            var urlComponents = URLComponents(string: baseURL + path)
            var queryItems = [URLQueryItem]()
            if let parameters {
                for (key, value) in parameters {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            urlComponents?.queryItems = queryItems
            guard let url = urlComponents?.url else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError.errorForAirwallexSDK(with: NSLocalizedString("Invalid URL format.", comment: "Invalid URL format."))))
                }
                return
            }
            request = URLRequest(url: url)
        } else if method == .POST {
            guard let url = URL(string: baseURL + path) else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError.errorForAirwallexSDK(with: NSLocalizedString("Invalid URL format.", comment: "Invalid URL format."))))
                }
                return
            }
            request = URLRequest(url: url)
            request.httpBody = payload
        } else {
            guard let url = URL(string: baseURL + path) else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError.errorForAirwallexSDK(with: NSLocalizedString("Invalid URL format.", comment: "Invalid URL format."))))
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
        } else {
            logMessage("Client secret is not set!")
        }

        logMessage("ULR request: \(request.url?.absoluteString ?? "")")
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let url = request.url else {
                let message = NSLocalizedString("No URL.", comment: "No URL.")
                self?.logMessage(message)
                DispatchQueue.main.async {
                    completion(.failure(NSError.errorForAirwallexSDK(with: message)))
                }
                return
            }

            if let error {
                AWXAnalyticsLogger.shared().logError(withName: eventName, url: url, response: AWXAPIErrorResponse(message: error.localizedDescription, code: "\((response as? HTTPURLResponse)?.statusCode ?? -1) "))
                self?.logMessage(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data else {
                let message = NSLocalizedString("No data.", comment: "No data.")
                self?.logMessage(message)
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError.errorForAirwallexSDK(with: message)))
                }
                return
            }

            if let httpCode = (response as? HTTPURLResponse)?.statusCode, httpCode >= 200, httpCode < 300 {
                if let decodedData = T.from(data) {
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } else {
                    let message = NSLocalizedString("Fail to decode data.", comment: "Fail to decode data.")
                    self?.logMessage(message)
                    DispatchQueue.main.async {
                        completion(
                            .failure(
                                NSError.errorForAirwallexSDK(with: message)))
                    }
                }
            } else {
                if let apiError = T.parseError(data) {
                    AWXAnalyticsLogger.shared().logError(withName: eventName, url: url, response: apiError)
                    self?.logMessage(apiError.message)
                    DispatchQueue.main.async {
                        completion(
                            .failure(
                                NSError.errorForAirwallexSDK(with: Int(apiError.code) ?? -1, localizedDescription: apiError.message)))
                    }
                    return
                } else {
                    let message = NSLocalizedString("Fail to decode error data.", comment: "Fail to decode error data.")
                    self?.logMessage(message)
                    DispatchQueue.main.async {
                        completion(
                            .failure(
                                NSError.errorForAirwallexSDK(with: message)))
                    }
                }
            }
        }
        task.resume()
    }

    public func get<T: Decodable>(
        path: String,
        parameters: [String: String]? = nil,
        eventName: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        performRequest(
            path: path, method: .GET, parameters: parameters, eventName: eventName, completion: completion
        )
    }

    public func post<T: Decodable>(
        path: String,
        payload: Encodable,
        eventName: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let data = try? JSONEncoder().encode(payload)
        performRequest(
            path: path, method: .POST, payload: data, eventName: eventName, completion: completion
        )
    }
}
