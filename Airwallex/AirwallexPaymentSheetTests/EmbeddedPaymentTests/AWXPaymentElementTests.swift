//
//  AWXPaymentElementTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPaymentSheet
import XCTest

@MainActor
final class AWXPaymentElementTests: XCTestCase {

    var mockViewController: MockPaymentResultDelegate!
    var mockMethodProvider: MockMethodProvider!

    override func setUp() {
        super.setUp()
        mockViewController = MockPaymentResultDelegate()
        mockMethodProvider = MockMethodProvider(methods: [], consents: [])
    }

    override func tearDown() {
        mockViewController = nil
        mockMethodProvider = nil
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
}
