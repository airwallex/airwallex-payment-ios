//
//  AWXPaymentElementTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
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

    // MARK: - Configuration Tests

    func testConfiguration_DefaultLayout_IsTab() {
        let configuration = AWXPaymentElement.Configuration()
        XCTAssertEqual(configuration.layout, .tab)
    }

    func testConfiguration_CanSetAccordionLayout() {
        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion
        XCTAssertEqual(configuration.layout, .accordion)
    }

    // MARK: - Static Create Tests

    func testCreate_WithMockProvider_ReturnsElement() async throws {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = try await AWXPaymentElement.create(
            hostViewController: mockViewController,
            session: mockMethodProvider.session,
            methodProvider: mockMethodProvider,
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
                hostViewController: mockViewController,
                session: invalidSession,
                methodProvider: mockMethodProvider,
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
                hostViewController: mockViewController,
                session: mockMethodProvider.session,
                methodProvider: mockMethodProvider,
                delegate: mockViewController
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected - getPaymentMethodTypes should fail
        }
    }

    func testCreate_WithAccordionConfiguration_AppliesLayout() async throws {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = try await AWXPaymentElement.create(
            hostViewController: mockViewController,
            session: mockMethodProvider.session,
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        XCTAssertEqual(element.paymentUIContext.layout, .accordion)
        XCTAssertTrue(element.paymentUIContext.isEmbedded)

        let sections = element.sections()
        XCTAssertFalse(sections.contains(.methodList))
        let hasAccordion = sections.contains(.accordion(.top)) || sections.contains(.accordion(.bottom))
        XCTAssertTrue(hasAccordion, "Accordion configuration should result in accordion sections")
    }

    func testCreate_WithDefaultConfiguration_UsesTabLayout() async throws {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = try await AWXPaymentElement.create(
            hostViewController: mockViewController,
            session: mockMethodProvider.session,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertEqual(element.paymentUIContext.layout, .tab)
        XCTAssertTrue(element.paymentUIContext.isEmbedded)

        let sections = element.sections()
        XCTAssertTrue(sections.contains(.methodList))
        XCTAssertFalse(sections.contains(.accordion(.top)))
        XCTAssertFalse(sections.contains(.accordion(.bottom)))
    }

    // MARK: - PaymentUIContext Initialization Tests

    func testInit_PaymentUIContext_IsEmbeddedTrue() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertTrue(element.paymentUIContext.isEmbedded)
    }

    func testInit_PaymentUIContext_DefaultLayoutIsTab() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertEqual(element.paymentUIContext.layout, .tab)
    }

    func testInit_PaymentUIContext_LayoutFromConfiguration() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        XCTAssertEqual(element.paymentUIContext.layout, .accordion)
    }

    func testInit_PaymentUIContext_DelegateIsSet() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertTrue(element.paymentUIContext.delegate === mockViewController)
    }

    func testInit_PaymentUIContext_ViewControllerIsSet() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertTrue(element.paymentUIContext.viewController === mockViewController)
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

    // MARK: - Section Tests (Tab Layout)

    func testSections_TabLayout_WithCardOnly_ReturnsCardSection() {
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
        XCTAssertFalse(sections.contains(.methodList), "Single method should not show method list")
    }

    func testSections_TabLayout_WithApplePay_IncludesApplePaySection() {
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

    func testSections_TabLayout_WithAlipay_IncludesSchemaSection() {
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

    func testSections_TabLayout_WithCardConsents_ReturnsConsentSection() {
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

    func testSections_TabLayout_WithMultipleMethods_IncludesMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.methodList), "Tab layout with multiple methods should include methodList")
        XCTAssertFalse(sections.contains(.accordion(.top)), "Tab layout should not include accordion sections")
        XCTAssertFalse(sections.contains(.accordion(.bottom)), "Tab layout should not include accordion sections")
    }

    func testSections_TabLayout_WithApplePayAndOneOther_ExcludesMethodList() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        mockMethodProvider.methods = [applePayMethod, cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        // With ApplePay + 1 other method, methodList should not appear
        // displayMethodList requires: methods.count > 1 + (isApplePayAvailable ? 1 : 0)
        // Here: 2 > 1 + 1 = 2 > 2 = false
        XCTAssertFalse(sections.contains(.methodList))
        XCTAssertTrue(sections.contains(.applePay))
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    func testSections_TabLayout_WithApplePayAndTwoOthers_IncludesMethodList() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [applePayMethod, cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        // With ApplePay + 2 other methods: 3 > 1 + 1 = 3 > 2 = true
        XCTAssertTrue(sections.contains(.methodList))
        XCTAssertTrue(sections.contains(.applePay))
    }

    // MARK: - Section Tests (Accordion Layout)

    func testSections_AccordionLayout_WithMultipleMethods_ReturnsAccordionSections() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let aliPayMethod = AWXPaymentMethodType()
        aliPayMethod.name = "alipaycn"

        mockMethodProvider.methods = [cardMethod, aliPayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion
        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        let hasAccordionTop = sections.contains(.accordion(.top))
        let hasAccordionBottom = sections.contains(.accordion(.bottom))
        XCTAssertTrue(hasAccordionTop || hasAccordionBottom, "Should have at least one accordion section")
    }

    func testSections_AccordionLayout_ExcludesMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertFalse(sections.contains(.methodList), "Accordion layout should not include methodList")
    }

    func testSections_AccordionLayout_IncludesCardPayment() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            hostViewController: mockViewController,
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.cardPaymentNew))
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
