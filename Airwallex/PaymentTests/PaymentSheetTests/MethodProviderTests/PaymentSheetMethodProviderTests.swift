//
//  PaymentSheetMethodProviderTests.swift
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

@MainActor class PaymentSheetMethodProviderTests: XCTestCase {

    var mockSuccessResponse: URLResponse!
    var mockFailureResponse: URLResponse!
    var provider: PaymentSheetMethodProvider!
    var mockAPIClient: AWXAPIClient!
    var mockMethodTypesData: Data!
    var mockConsentsData: Data!
    var mockAXSKioskData: Data!
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
        
        mockMethodTypesData = Bundle.dataOfFile("method_types")!
        mockConsentsData = Bundle.dataOfFile("payment_consents")!
        mockAXSKioskData = Bundle.dataOfFile("method_type_axs_kiosk")
        
        provider = PaymentSheetMethodProvider(
            session: mockSession,
            apiClient: mockAPIClient
        )
        updates = [PaymentMethodProviderUpdateType]()
        cancellable = provider.updatePublisher.sink { [weak self] update in
            self?.updates.append(update)
        }
    }
    
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.resetMockResponses()
        updates = nil
    }
    
    func testFetchPaymentMethod() async {
        MockURLProtocol.mockResponseQueue = [(mockMethodTypesData, mockSuccessResponse, nil), (mockConsentsData, mockSuccessResponse, nil)]
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(provider.methods.count, 14)
        XCTAssertEqual(provider.selectedMethod?.name, provider.methods.first { $0.name != AWXApplePayKey }?.name)
        XCTAssertEqual(provider.consents.count, 0)
        XCTAssertEqual(provider.session, mockSession)
        XCTAssertEqual(provider.selectedMethod?.transactionMode, mockSession.transactionMode())
        XCTAssertEqual(provider.selectedMethod?.transactionMode, provider.session.transactionMode())
        XCTAssertFalse(provider.isApplePayAvailable)
        XCTAssertNil(provider.applePayMethodType)

        guard case PaymentMethodProviderUpdateType.methodSelected(_) = updates.first!,
              case PaymentMethodProviderUpdateType.listUpdated = updates.last! else {
            XCTFail()
            return
        }
    }
    
    func testFetchPaymentMethodWithApplePayOptions() async {
        MockURLProtocol.mockResponseQueue = [(mockMethodTypesData, mockSuccessResponse, nil), (mockConsentsData, mockSuccessResponse, nil)]
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "123")
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(provider.methods.count, 15)
        XCTAssertEqual(provider.selectedMethod?.name, provider.methods.first { $0.name != AWXApplePayKey }?.name)
        XCTAssertEqual(provider.consents.count, 0)
        XCTAssertEqual(provider.session, mockSession)
        XCTAssertEqual(provider.selectedMethod?.transactionMode, mockSession.transactionMode())
        XCTAssertEqual(provider.selectedMethod?.transactionMode, provider.session.transactionMode())
        XCTAssertTrue(provider.isApplePayAvailable)
        XCTAssertNotNil(provider.applePayMethodType)

        guard case PaymentMethodProviderUpdateType.methodSelected(_) = updates.first!,
              case PaymentMethodProviderUpdateType.listUpdated = updates.last! else {
            XCTFail()
            return
        }
    }
    
    func testFetchPaymentMethodWithApplePayOptionsAndCustomerId() async {
        MockURLProtocol.mockResponseQueue = [(mockMethodTypesData, mockSuccessResponse, nil), (mockConsentsData, mockSuccessResponse, nil)]
        mockSession.applePayOptions = AWXApplePayOptions(merchantIdentifier: "123")
        let intent = AWXPaymentIntent()
        intent.id = "intent_id"
        intent.customerId = "customer_id"
        intent.clientSecret = "client_secret"
        (mockSession as? AWXOneOffSession)?.paymentIntent = intent
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(provider.methods.count, 15)
        XCTAssertEqual(provider.selectedMethod?.name, provider.methods.first { $0.name != AWXApplePayKey }?.name)
        XCTAssertEqual(provider.consents.count, 1)
        XCTAssertEqual(provider.session, mockSession)
        XCTAssertEqual(provider.selectedMethod?.transactionMode, mockSession.transactionMode())
        XCTAssertEqual(provider.selectedMethod?.transactionMode, provider.session.transactionMode())
        XCTAssertTrue(provider.isApplePayAvailable)
        XCTAssertNotNil(provider.applePayMethodType)

        guard case PaymentMethodProviderUpdateType.methodSelected(_) = updates.first!,
              case PaymentMethodProviderUpdateType.listUpdated = updates.last! else {
            XCTFail()
            return
        }
    }
    
    func testChangeSelectedMethod() async {
        MockURLProtocol.mockResponseQueue = [(mockMethodTypesData, mockSuccessResponse, nil), (mockConsentsData, mockSuccessResponse, nil)]
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        
        XCTAssertEqual(provider.selectedMethod?.name, provider.methods.first { $0.name != AWXApplePayKey }?.name)
        guard updates.count == 2 else {
            XCTFail("incorrect udpate count")
            return
        }
        guard case PaymentMethodProviderUpdateType.methodSelected(_) = updates.first!,
              case PaymentMethodProviderUpdateType.listUpdated = updates.last! else {
            XCTFail()
            return
        }
        updates.removeAll()
        let newSelectedMethod = provider.methods.last { $0.name != AWXApplePayKey }
        provider.selectedMethod = newSelectedMethod
        guard let update = updates.first else {
            XCTFail("no udpate observed")
            return
        }
        guard case PaymentMethodProviderUpdateType.methodSelected(_) = update else {
            XCTFail()
            return
        }
    }
}
