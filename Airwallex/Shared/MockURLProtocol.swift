//
//  MockURLProtocol.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
@testable @_spi(AWX) import AirwallexPayment

class MockURLProtocol: URLProtocol {
    static var mockResponse: (Data?, URLResponse?, Error?)?
    static var mockResponseMap: [String: (Data?, URLResponse?, Error?)]?
    static var responseDelay: UInt64 = UInt64.random(in: 1_000...2_000)
    
    static func resetMockResponses() {
        mockResponse = nil
        mockResponseMap = nil
        responseDelay = UInt64.random(in: 1_000...2_000)
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
        } else if let url = request.url, let (data, response, error) = Self.mockResponseMap?[url.path] {
            communicateClient(data, response, error)
        } else {
            assert(false, "mock response not found")
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
            try? await Task.sleep(nanoseconds: Self.responseDelay)
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
    
    static func mockSuccess(data: Data = Data(),
                            delay: UInt64 = UInt64.random(in: 1_000...2_000)) {
        let response = HTTPURLResponse(
            url: URL(string: "https://www.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        mockResponse = (data, response, nil)
        responseDelay = delay
    }
    
    static func mockFailure(withError error: Error? = nil,
                            delay: UInt64 = UInt64.random(in: 1_000...2_000)) {
        let response = HTTPURLResponse(
            url: URL(string: "https://www.example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        mockResponse = (nil, response, error)
        responseDelay = delay
    }
    
    static func mockSlowResponse(delay: UInt64 = 2_000_000_000) { // 2 seconds by default
        mockSuccess(delay: delay)
    }
}
