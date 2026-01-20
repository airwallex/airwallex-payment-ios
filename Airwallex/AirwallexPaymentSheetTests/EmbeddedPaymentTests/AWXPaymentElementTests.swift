//
//  AWXPaymentElementTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet
import XCTest

@MainActor
final class AWXPaymentElementTests: XCTestCase {

    var mockViewController: MockPaymentResultDelegate!
    var mockMethodProvider: MockMethodProvider!
    var mockAPIClient: AWXAPIClient!
    var mockSuccessResponse: URLResponse!
    var mockMethodTypesData: Data!
    var mockConsentsData: Data!

    override func setUp() {
        super.setUp()
        mockViewController = MockPaymentResultDelegate()
        mockMethodProvider = MockMethodProvider(methods: [], consents: [])

        // Setup mock API client for public API tests
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockAPIClient = AWXAPIClient(configuration: clientConfiguration)

        let mockURL = URL(string: "https://api-demo.airwallex.com/api/v1/pa/config/payment_method_types")!
        mockSuccessResponse = HTTPURLResponse(
            url: mockURL,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        mockMethodTypesData = Bundle.dataOfFile("method_types")!
        mockConsentsData = Bundle.dataOfFile("payment_consents")!
    }

    override func tearDown() {
        mockViewController = nil
        mockMethodProvider = nil
        mockAPIClient = nil
        MockURLProtocol.resetMockResponses()
        super.tearDown()
    }

    // MARK: - Static Create Tests

    func testCreate_WithMockProvider_ReturnsElement() async throws {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = try await AWXPaymentElement.create(
            session: mockMethodProvider.session,
            methodProvider: mockMethodProvider,
            hostViewController: mockViewController,
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
    }

    func testCreate_WithInvalidSession_ThrowsError() async {
        let invalidSession = AWXOneOffSession()
        invalidSession.countryCode = "AU"
        // No paymentIntent set - should fail validation

        do {
            _ = try await AWXPaymentElement.create(
                session: invalidSession,
                methodProvider: mockMethodProvider,
                hostViewController: mockViewController,
                delegate: mockViewController
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected - session validation should fail
        }
    }

    func testCreate_WhenGetPaymentMethodTypesFails_ThrowsError() async {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]

        // Set error to be thrown
        mockMethodProvider.getPaymentMethodTypesError = NSError(
            domain: "TestError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to fetch payment methods"]
        )

        do {
            _ = try await AWXPaymentElement.create(
                session: mockMethodProvider.session,
                methodProvider: mockMethodProvider,
                hostViewController: mockViewController,
                delegate: mockViewController
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected - getPaymentMethodTypes should fail
        }
    }

    // MARK: - View Tests

    func testView_IsNotNil() async {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertNotNil(element.view)
        element.view.translatesAutoresizingMaskIntoConstraints = false
        element.view.widthAnchor.constraint(equalToConstant: 375).isActive = true
        element.view.layoutIfNeeded()
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(element.view.bounds.height > 0)
    }

    func testDelegate_Setter() {

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: SinglePaymentMethodProvider(
                session: createValidSession(),
                name: AWXCardKey
            ),
            delegate: mockViewController
        )
        XCTAssert(element.delegate === mockViewController)

        let newDelegate = MockPaymentResultDelegate()
        element.delegate = newDelegate
        XCTAssert(element.delegate === newDelegate)
        XCTAssert(element.delegate !== mockViewController)
    }

    // MARK: - Section Tests

    func testSections_WithCardOnly_ReturnsCardSection() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.cardPaymentNew))
        XCTAssertFalse(sections.contains(.applePay))
    }

    func testSections_WithApplePay_IncludesApplePaySection() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey
        mockMethodProvider.methods = [applePayMethod]
        
        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )
        
        let sections = element.sections()
        
        XCTAssertTrue(sections.contains(.applePay))
    }
    
    func testSections_WithAlipay_IncludesAlipaySection() {
        let mockAlipay = AWXPaymentMethodType()
        mockAlipay.name = "alipayhk"
        mockAlipay.resources = AWXResources()
        mockAlipay.resources.hasSchema = true
        
        mockMethodProvider.methods = [mockAlipay]
        mockMethodProvider.selectedMethod = mockAlipay
        
        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )
        
        let sections = element.sections()
        
        XCTAssertTrue(sections.contains(.schemaPayment("alipayhk")))
    }

    func testSections_WithMultipleMethods_ReturnsAccordionSections() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let aliPayMethod = AWXPaymentMethodType()
        aliPayMethod.name = "alipaycn"

        mockMethodProvider.methods = [cardMethod, aliPayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        // With multiple methods, accordion sections should be present
        let hasAccordionTop = sections.contains(.accordion(.top))
        let hasAccordionBottom = sections.contains(.accordion(.bottom))
        XCTAssertTrue(hasAccordionTop || hasAccordionBottom, "Should have at least one accordion section")
    }

    func testSections_WithCardConsents_ReturnsConsentSection() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        // Add a consent
        let consent = AWXPaymentConsent()
        consent.id = "consent_id"
        let paymentMethod = AWXPaymentMethod()
        paymentMethod.type = AWXCardKey
        consent.paymentMethod = paymentMethod
        mockMethodProvider.consents = [consent]

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.cardPaymentConsent))
        XCTAssertFalse(sections.contains(.cardPaymentNew))
    }

    // MARK: - Section Controller Tests

    func testSectionController_WithUnexpectedSectionType_ReturnsFallbackController() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        // Call sectionController with a section type that's not expected by AWXPaymentElement
        // This exercises the default case in the switch statement
        let controller = element.sectionController(for: .listTitle)

        // The fallback controller should still return a valid controller
        XCTAssertNotNil(controller)
    }

    // MARK: - Public API Tests

    private func createValidSession() -> Session {
        let intent = AWXPaymentIntent()
        intent.id = "intent_id"
        intent.clientSecret = "client_secret"
        intent.amount = NSDecimalNumber(value: 100)
        intent.currency = "AUD"

        return Session(
            paymentIntent: intent,
            countryCode: "AU"
        )
    }

    func testPublicCreate_WithSessionAndHostViewController_ReturnsElement() async throws {
        MockURLProtocol.mockResponseMap = [
            AWXGetPaymentMethodTypesRequest().path(): (mockMethodTypesData, mockSuccessResponse, nil),
            AWXGetPaymentConsentsRequest().path(): (mockConsentsData, mockSuccessResponse, nil)
        ]

        let session = createValidSession()

        AWXAPIClientConfiguration.shared().sessionConfiguration = {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [MockURLProtocol.self]
            return config
        }()

        let element = try await AWXPaymentElement.create(
            session: session,
            hostViewController: mockViewController,
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
        XCTAssertTrue(element.delegate === mockViewController)

        AWXAPIClientConfiguration.shared().sessionConfiguration = nil
    }

    func testPublicCreate_WithSessionAndCombinedDelegate_ReturnsElement() async throws {
        MockURLProtocol.mockResponseMap = [
            AWXGetPaymentMethodTypesRequest().path(): (mockMethodTypesData, mockSuccessResponse, nil),
            AWXGetPaymentConsentsRequest().path(): (mockConsentsData, mockSuccessResponse, nil)
        ]

        let session = createValidSession()

        AWXAPIClientConfiguration.shared().sessionConfiguration = {
            let config = URLSessionConfiguration.ephemeral
            config.protocolClasses = [MockURLProtocol.self]
            return config
        }()

        let element = try await AWXPaymentElement.create(
            session: session,
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
        XCTAssertTrue(element.delegate === mockViewController)

        AWXAPIClientConfiguration.shared().sessionConfiguration = nil
    }

    func testPublicCreate_WithMethodNameCard_ReturnsElementWithoutAPICall() async throws {
        // Card payment method doesn't require API call - SinglePaymentMethodProvider creates it locally
        let session = createValidSession()

        let element = try await AWXPaymentElement.create(
            methodName: AWXCardKey,
            session: session,
            hostViewController: mockViewController,
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
        XCTAssertTrue(element.delegate === mockViewController)

        let sections = element.sections()
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    func testPublicCreate_WithMethodNameCardAndCombinedDelegate_ReturnsElement() async throws {
        let session = createValidSession()

        let element = try await AWXPaymentElement.create(
            methodName: AWXCardKey,
            session: session,
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
        XCTAssertTrue(element.delegate === mockViewController)

        let sections = element.sections()
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    func testPublicCreate_WithMethodNameCardAndSupportedBrands_ReturnsElement() async throws {
        let session = createValidSession()

        let element = try await AWXPaymentElement.create(
            methodName: AWXCardKey,
            supportedBrands: [.visa, .mastercard],
            session: session,
            hostViewController: mockViewController,
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
        XCTAssertTrue(element.delegate === mockViewController)
    }

    func testPublicCreate_WithInvalidSession_ThrowsError() async {
        let invalidSession = Session(
            paymentIntent: AWXPaymentIntent(),
            countryCode: "AU"
        )
        // paymentIntent has no clientSecret - should fail validation

        do {
            _ = try await AWXPaymentElement.create(
                methodName: AWXCardKey,
                session: invalidSession,
                hostViewController: mockViewController,
                delegate: mockViewController
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is AWXUIContext.LaunchError)
        }
    }
}
