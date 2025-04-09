//
//  MockURLProtocol.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
@testable import Payment

class MockURLProtocol: URLProtocol {
    static var mockResponse: (Data?, URLResponse?, Error?)?
    static var mockResponseMap: [URL: (Data?, URLResponse?, Error?)]?
    static var mockResponseQueue: [(Data?, URLResponse?, Error?)]?
    
    static func resetMockResponses() {
        mockResponse = nil
        mockResponseMap = nil
        mockResponseQueue = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let (data, response, error) = Self.mockResponse {
            communicateClient(data, response, error)
        } else if let url = request.url, let (data, response, error) = Self.mockResponseMap?[url] {
            communicateClient(data, response, error)
        } else if let responseQueue = Self.mockResponseQueue {
            if responseQueue.isEmpty {
                communicateClient(nil, nil, "unexpected requrest".asError())
            } else {
                let (data, response, error) = Self.mockResponseQueue!.removeFirst()
                communicateClient(data, response, error)
            }
        }
    }
    
    private func communicateClient(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        Task {
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            try? await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...1_000_000_000))
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
