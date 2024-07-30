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
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, expectedData)
        }

        let expectation = self.expectation(description: "GET request should succeed")
        
        AWXNetWorkManager.shared.get(urlString: "dummyendpoint", parameters: nil) { (result: Result<TestResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.message, "Success")
            case .failure(let error):
                XCTFail("Expected success but got \(error)")
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
        let expectedData = try! JSONSerialization.data(withJSONObject: expectedResponse, options: .prettyPrinted)


        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            guard let httpBody = request.httpBody else {
                XCTFail("HTTPBody is nil")
                return (HTTPURLResponse(), Data())
            }
            let body = try JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: String]
            XCTAssertEqual(body?["key"], postData["key"])
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, expectedData)
        }

        let expectation = self.expectation(description: "POST request should succeed")
        
        AWXNetWorkManager.shared.post(urlString: "dummyendpoint", parameters: postData) { (result: Result<TestResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.message, "Success")
            case .failure(let error):
                XCTFail("Expected success but got \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}

// A sample response model
class TestResponse: Codable {
    let message: String
}
