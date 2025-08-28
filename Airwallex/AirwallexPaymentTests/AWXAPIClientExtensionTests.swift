//
//  AWXAPIClientExtensionTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 28/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
import Foundation
import XCTest

class AWXAPIClientExtensionTests: XCTestCase {
    
    private var mockApiClient: AWXAPIClient!
    
    override func setUp() {
        super.setUp()
        
        // Create mock API client with MockURLProtocol
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockApiClient = AWXAPIClient(configuration: clientConfiguration)
    }
    
    // MARK: - SendRequest Tests
    
    func testSendRequestSuccess() async throws {
        
        // Create a mock request
        let request = AWXConfirmPaymentIntentRequest()
        
        // Set up mock success response
        MockURLProtocol.mockSuccess()
        
        // Send the request and test for success
        do {
            let response: AWXConfirmPaymentIntentResponse = try await mockApiClient.sendRequest(request)
            XCTAssertNotNil(response)
        } catch {
            XCTFail("Request should not have failed: \(error)")
        }
    }
    
    func testSendRequestError() async {
        
        // Create a mock request
        let request = AWXConfirmPaymentIntentRequest()
        
        // Set up mock network error
        let mockError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        MockURLProtocol.mockFailure(withError: mockError)
        
        // Send the request and test for network error
        do {
            let _: AWXConfirmPaymentIntentResponse = try await mockApiClient.sendRequest(request)
            XCTFail("Request should have failed with network error")
        } catch {
            XCTAssertEqual((error as NSError).domain, NSURLErrorDomain)
            XCTAssertEqual((error as NSError).code, NSURLErrorNotConnectedToInternet)
        }
    }
}
