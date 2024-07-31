//
//  AWXNetWorkManagerTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/30.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import XCTest

@testable import Core

class AWXNetWorkManagerTests: XCTestCase {
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        AWXNetWorkManager.shared.session = mockSession
    }

    override func tearDown() {
        mockSession = nil
        super.tearDown()
    }

    func test_GETRequest_success() {
        // Prepare mock response
        let url = URL(string: "https://api.airwallex.com/dummyendpoint?")!
        let expectedData = """
        {
            "message": "Success"
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: url, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, expectedData)
        }

        let expectation = self.expectation(description: "GET request should succeed")

        AWXNetWorkManager.shared.get(urlString: "dummyendpoint", parameters: nil) {
            (result: Result<TestResponse, Error>) in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.message, "Success")
            case let .failure(error):
                XCTFail("Expected success but got \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test_GETRequest_withParameters_success() {
        // Prepare mock response
        let url = URL(string: "https://api.airwallex.com/dummyendpoint?key1=value1&key2=value2")!
        let expectedData = """
        {
            "message": "Success"
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: url, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, expectedData)
        }

        let expectation = self.expectation(description: "GET request with parameters should succeed")

        let parameters = ["key1": "value1", "key2": "value2"]

        AWXNetWorkManager.shared.get(urlString: "dummyendpoint", parameters: parameters) {
            (result: Result<TestResponse, Error>) in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.message, "Success")
            case let .failure(error):
                XCTFail("Expected success but got \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test_GETRequest_networkError() {
        // Prepare an error
        let networkError = NSError(
            domain: "NetworkError", code: -1001,
            userInfo: [NSLocalizedDescriptionKey: "The request timed out."]
        )

        // Set up the mock protocol to return the error
        MockURLProtocol.requestHandler = { _ in
            throw networkError
        }

        let expectation = self.expectation(description: "GET request should fail with network error")

        AWXNetWorkManager.shared.get(urlString: "dummyendpoint", parameters: nil) {
            (result: Result<TestResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case let .failure(error as NSError):
                XCTAssertEqual(error.domain, "NetworkError")
                XCTAssertEqual(error.code, -1001)
                XCTAssertEqual(
                    error.userInfo[NSLocalizedDescriptionKey] as? String, "The request timed out."
                )
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test_GETRequest_failToDecodeData() {
        // Prepare mock response with invalid data that cannot be decoded to TestResponse
        let invalidData = "Invalid Data".data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            let url = URL(string: "https://api.airwallex.com/dummyendpoint?")!
            let response = HTTPURLResponse(
                url: url, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, invalidData)
        }

        let expectation = self.expectation(description: "GET request should fail to decode data")

        AWXNetWorkManager.shared.get(urlString: "dummyendpoint", parameters: nil) {
            (result: Result<TestResponse, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case let .failure(error as NSError):
                XCTAssertEqual(error.domain, AWXSDKErrorDomain)
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual(error.userInfo[NSLocalizedDescriptionKey] as? String, "Fail to decode data.")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test_POSTRequest_success() {
        // Prepare mock response
        let url = URL(string: "https://api.airwallex.com/dummyendpoint")!
        let postData = ["key": "value"]
        let expectedResponse = ["message": "Success"]
        let expectedData = try! JSONSerialization.data(
            withJSONObject: expectedResponse, options: .prettyPrinted
        )

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            guard let httpBody = request.httpBody else {
                XCTFail("HTTPBody is nil")
                return (HTTPURLResponse(), Data())
            }
            let body = try JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: String]
            XCTAssertEqual(body?["key"], postData["key"])
            let response = HTTPURLResponse(
                url: url, statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, expectedData)
        }

        let expectation = self.expectation(description: "POST request should succeed")

        AWXNetWorkManager.shared.post(urlString: "dummyendpoint", parameters: postData) {
            (result: Result<TestResponse, Error>) in
            switch result {
            case let .success(response):
                XCTAssertEqual(response.message, "Success")
            case let .failure(error):
                XCTFail("Expected success but got \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test_baseUrl() {
        Airwallex.setMode(.demoMode)
        XCTAssertEqual(AWXNetWorkManager.shared.baseURL, "https://api-demo.airwallex.com/")
        Airwallex.setMode(.productionMode)
        XCTAssertEqual(AWXNetWorkManager.shared.baseURL, "https://api.airwallex.com/")
        Airwallex.setMode(.stagingMode)
        XCTAssertEqual(AWXNetWorkManager.shared.baseURL, "https://api-staging.airwallex.com/")
    }
}

// A sample response model
class TestResponse: Codable {
    let message: String
}
