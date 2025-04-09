//
//  SinglePaymentMethodProviderTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment
import Core
import Combine

@MainActor class SinglePaymentMethodProviderTests: XCTestCase {

    var mockSuccessResponse: URLResponse!
    var mockFailureResponse: URLResponse!
    var provider: SinglePaymentMethodProvider!
    var mockAPIClient: AWXAPIClient!
    var mockData: Data!
    var mockSession: AWXSession!
    var updates: [PaymentMethodProviderUpdateType]!
    var cancellable: AnyCancellable?
    
    override func setUp() {
        super.setUp()
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockAPIClient = AWXAPIClient(configuration: clientConfiguration)
        mockSession = AWXOneOffSession()
        
        let mockURL = URL(string: "https://api-demo.airwallex.com/api/v1/pa/config/payment_method_types/card?flow=inapp&transaction_mode=oneoff")!
        mockSuccessResponse = HTTPURLResponse(
            url: mockURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        mockFailureResponse = HTTPURLResponse(
            url: mockURL,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        mockData = Bundle.dataOfFile("method_type_card")!
        provider = SinglePaymentMethodProvider(
            session: mockSession,
            name: AWXCardKey,
            supportedCardBrands: AWXCardBrand.all
        )
        provider.apiClient = mockAPIClient
        updates = [PaymentMethodProviderUpdateType]()
        cancellable = provider.updatePublisher.sink { [weak self] update in
            self?.updates.append(update)
        }
    }
    
    override class func tearDown() {
        super.tearDown()
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockResponseMap = nil
    }
    
    func testNilForSupportedCardBrand() async {
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        provider = SinglePaymentMethodProvider(
            session: mockSession,
            name: AWXCardKey
        )
        provider.apiClient = mockAPIClient
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map {$0.name },
                       AWXCardScheme.allAvailable.map { $0.name })
    }
    
    func testSupportedCardBrands() async {
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        provider = SinglePaymentMethodProvider(
            session: mockSession,
            name: AWXCardKey,
            supportedCardBrands: [.amex, .visa, .mastercard]
        )
        provider.apiClient = mockAPIClient
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map {$0.name },
                       [AWXCardBrand.amex, AWXCardBrand.visa, AWXCardBrand.mastercard].map { $0.rawValue })
    }
    
    func testFetchPaymentMethod() async {
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        let model: AWXPaymentMethodType = Bundle.decode(file: "method_type_card")!
        XCTAssert(provider.methods.count == 1)
        XCTAssert(provider.selectedMethod?.name == model.name)
        XCTAssertEqual(provider.methods.first?.name, model.name)
        guard case PaymentMethodProviderUpdateType.methodSelected(_) = updates.first!,
              case PaymentMethodProviderUpdateType.listUpdated = updates.last! else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(provider.session, mockSession)
        XCTAssertEqual(provider.selectedMethod?.transactionMode, mockSession.transactionMode())
        XCTAssertEqual(provider.selectedMethod?.transactionMode, provider.session.transactionMode())
        XCTAssertFalse(provider.isApplePayAvailable)
        XCTAssertNil(provider.applePayMethodType)
        XCTAssertEqual(provider.method(named: AWXCardKey), provider.selectedMethod)
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map {$0.name },
                       AWXCardScheme.allAvailable.map { $0.name })
    }

    func testfetchPaymentMethodDetailsMultipleTimes() async {
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        MockURLProtocol.mockResponseQueue = [(mockData, mockSuccessResponse, nil)]
        do {
            async let methodDetail1 = provider.getPaymentMethodTypeDetails(name: provider.name)
            async let methodDetail2 = provider.getPaymentMethodTypeDetails(name: provider.name)
            _ = try await (provider.getPaymentMethodTypes(), methodDetail1, methodDetail2)
        } catch {
            XCTFail()
        }
    }
}
