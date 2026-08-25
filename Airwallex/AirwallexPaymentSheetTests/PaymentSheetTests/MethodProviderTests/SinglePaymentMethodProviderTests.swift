//
//  SinglePaymentMethodProviderTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/2.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import Combine
import UIKit
import XCTest

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
            supportedCardBrands: AWXCardBrand.allAvailable
        )
        provider.apiClient = mockAPIClient
        updates = [PaymentMethodProviderUpdateType]()
        cancellable = provider.updatePublisher.sink { [weak self] update in
            self?.updates.append(update)
        }
    }
    
    override class func tearDown() {
        super.tearDown()
        MockURLProtocol.resetMockResponses()
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
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map { $0.name },
                       AWXCardScheme.allAvailable.map { $0.name })
    }

    func testCardDisplayNameUsesSelectedLanguage() async throws {
        let session = Session(
            paymentIntent: AWXPaymentIntent(),
            countryCode: "AU",
            lang: "ja-JP"
        )
        provider = SinglePaymentMethodProvider(
            session: session,
            name: AWXCardKey
        )
        try await provider.getPaymentMethodTypes()
        XCTAssertEqual(provider.methods.first?.displayName, "カード")
        session.lang = "de"
        XCTAssertEqual(provider.language, .japanese)
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
        // Maestro is appended because the supported brands include Mastercard
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map { $0.name },
                       [AWXCardBrand.amex, AWXCardBrand.visa, AWXCardBrand.mastercard, AWXCardBrand.maestro].map { $0.rawValue })
    }

    func testMaestroNotAddedWithoutMastercard() async {
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        provider = SinglePaymentMethodProvider(
            session: mockSession,
            name: AWXCardKey,
            supportedCardBrands: [.visa, .unionPay]
        )
        provider.apiClient = mockAPIClient
        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail()
        }
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map { $0.name },
                       [AWXCardBrand.visa, AWXCardBrand.unionPay].map { $0.rawValue })
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
        XCTAssertEqual(provider.selectedMethod?.cardSchemes.map { $0.name },
                       AWXCardScheme.allAvailable.map { $0.name })
    }

    func testfetchPaymentMethodDetailsMultipleTimes() async {
        MockURLProtocol.mockResponse = (mockData, mockSuccessResponse, nil)
        do {
            async let methodDetail1 = provider.getPaymentMethodTypeDetails(name: provider.name)
            async let methodDetail2 = provider.getPaymentMethodTypeDetails(name: provider.name)
            _ = try await (provider.getPaymentMethodTypes(), methodDetail1, methodDetail2)
        } catch {
            XCTFail()
        }
    }

    func testFetchOnlineBankingPaymentMethod() async {
        let onlineBankingData = Bundle.dataOfFile("method_type_online_banking")!
        let mockURL = URL(string: "https://api-demo.airwallex.com/api/v1/pa/config/payment_method_types/online_banking?flow=inapp&transaction_mode=oneoff")!
        let onlineBankingSuccessResponse = HTTPURLResponse(
            url: mockURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        MockURLProtocol.mockResponse = (onlineBankingData, onlineBankingSuccessResponse, nil)

        mockSession.lang = "ja-JP"
        provider = SinglePaymentMethodProvider(
            session: mockSession,
            name: "online_banking"
        )
        mockSession.lang = "de"
        provider.apiClient = mockAPIClient

        updates = [PaymentMethodProviderUpdateType]()
        cancellable = provider.updatePublisher.sink { [weak self] update in
            self?.updates.append(update)
        }

        do {
            try await provider.getPaymentMethodTypes()
        } catch {
            XCTFail("Failed to fetch online banking payment method: \(error)")
        }

        let model: AWXPaymentMethodType = Bundle.decode(file: "method_type_online_banking")!

        XCTAssertEqual(provider.methods.count, 1)
        XCTAssertEqual(provider.selectedMethod?.name, "online_banking")
        XCTAssertEqual(provider.selectedMethod?.displayName, model.displayName)
        XCTAssertEqual(provider.methods.first?.name, model.name)
        XCTAssertTrue(provider.selectedMethod?.resources.hasSchema ?? false)

        guard case PaymentMethodProviderUpdateType.methodSelected(_) = updates.first!,
              case PaymentMethodProviderUpdateType.listUpdated = updates.last! else {
            XCTFail("Expected methodSelected and listUpdated updates")
            return
        }

        XCTAssertEqual(provider.session, mockSession)
        XCTAssertEqual(provider.language, .japanese)
        XCTAssertEqual(
            MockURLProtocol.lastRequest?.url
                .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
                .queryItems?
                .first { $0.name == "lang" }?
                .value,
            "ja"
        )
        XCTAssertEqual(provider.selectedMethod?.transactionMode, mockSession.transactionMode())
        XCTAssertFalse(provider.isApplePayAvailable)
        XCTAssertNil(provider.applePayMethodType)
        XCTAssertEqual(provider.method(named: "online_banking"), provider.selectedMethod)
    }
}
