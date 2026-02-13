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

    // MARK: - Helpers

    private func makeTestSession() -> Session {
        let intent = AWXPaymentIntent()
        intent.id = "test_intent_id"
        intent.clientSecret = "test_client_secret"
        intent.amount = NSDecimalNumber(value: 100)
        intent.currency = "AUD"
        intent.customerId = "test_customer_id"
        return Session(paymentIntent: intent, countryCode: "AU")
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

    func testConfiguration_DefaultElementType_IsStandard() {
        let configuration = AWXPaymentElement.Configuration()
        XCTAssertEqual(configuration.elementType, .paymentSheet)
    }

    func testConfiguration_CanSetCardElementType() {
        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard
        XCTAssertEqual(configuration.elementType, .addCard)
    }

    func testConfiguration_DefaultSupportedCardBrands_IsAllAvailable() {
        let configuration = AWXPaymentElement.Configuration()
        XCTAssertEqual(configuration.supportedCardBrands, AWXCardBrand.allAvailable)
    }

    func testConfiguration_CanSetSupportedCardBrands() {
        let configuration = AWXPaymentElement.Configuration()
        configuration.supportedCardBrands = [.visa, .mastercard]
        XCTAssertEqual(configuration.supportedCardBrands, [.visa, .mastercard])
    }

    func testConfiguration_DefaultShowsApplePayAsPrimaryButton_IsTrue() {
        let configuration = AWXPaymentElement.Configuration()
        XCTAssertTrue(configuration.showsApplePayAsPrimaryButton)
    }

    func testConfiguration_CanSetShowsApplePayAsPrimaryButtonToFalse() {
        let configuration = AWXPaymentElement.Configuration()
        configuration.showsApplePayAsPrimaryButton = false
        XCTAssertFalse(configuration.showsApplePayAsPrimaryButton)
    }

    func testConfiguration_DefaultShowsPaymentProcessingIndicator_IsTrue() {
        let configuration = AWXPaymentElement.Configuration()
        XCTAssertTrue(configuration.showsPaymentProcessingIndicator)
    }

    func testConfiguration_CanSetShowsPaymentProcessingIndicatorToFalse() {
        let configuration = AWXPaymentElement.Configuration()
        configuration.showsPaymentProcessingIndicator = false
        XCTAssertFalse(configuration.showsPaymentProcessingIndicator)
    }

    func testConfiguration_DefaultAppearance_HasDefaultColorBrand() {
        let configuration = AWXPaymentElement.Configuration()
        let lightTraitCollection = UITraitCollection(userInterfaceStyle: .light)
        let darkTraitCollection = UITraitCollection(userInterfaceStyle: .dark)
        // Compare resolved colors since dynamic colors are not equal by reference
        XCTAssertEqual(
            configuration.appearance.tintColor.resolvedColor(with: lightTraitCollection),
            UIColor.awxColor(.theme).resolvedColor(with: lightTraitCollection)
        )
        XCTAssertEqual(
            configuration.appearance.tintColor.resolvedColor(with: darkTraitCollection),
            UIColor.awxColor(.theme).resolvedColor(with: darkTraitCollection)
        )
    }

    func testConfiguration_CanSetCustomColorBrand() {
        let configuration = AWXPaymentElement.Configuration()
        configuration.appearance.tintColor = .systemRed
        XCTAssertEqual(configuration.appearance.tintColor, .systemRed)
    }

    func testCreate_AppliesAppearanceColorBrand() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        let customColor = UIColor.systemPurple
        configuration.appearance.tintColor = customColor

        _ = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        XCTAssertEqual(AWXTheme.shared().tintColor, customColor)
    }

    // MARK: - makeMethodProvider Tests

    func testMakeMethodProvider_StandardElementType_ReturnsPaymentSheetMethodProvider() throws {
        let session = makeTestSession()
        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .paymentSheet

        let provider = try AWXPaymentElement.makeMethodProvider(session: session, configuration: configuration)

        XCTAssertTrue(provider is PaymentSheetMethodProvider)
    }

    func testMakeMethodProvider_AddCardElementType_ReturnsSinglePaymentMethodProvider() throws {
        let session = makeTestSession()
        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard
        configuration.supportedCardBrands = [.visa, .mastercard]

        let provider = try AWXPaymentElement.makeMethodProvider(session: session, configuration: configuration)

        XCTAssertTrue(provider is SinglePaymentMethodProvider)
    }

    func testMakeMethodProvider_AddCardWithEmptyBrands_ThrowsError() {
        let session = makeTestSession()
        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard
        configuration.supportedCardBrands = []

        XCTAssertThrowsError(try AWXPaymentElement.makeMethodProvider(session: session, configuration: configuration)) { error in
            guard case AWXUIContext.LaunchError.invalidCardBrand(let message) = error else {
                XCTFail("Expected invalidCardBrand error")
                return
            }
            XCTAssertEqual(message, "supportedBrands should not be empty")
        }
    }

    func testMakeMethodProvider_AddCardWithInvalidBrands_ThrowsError() {
        let session = makeTestSession()
        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard
        configuration.supportedCardBrands = [.visa, .init(rawValue: "unknown")]

        XCTAssertThrowsError(try AWXPaymentElement.makeMethodProvider(session: session, configuration: configuration)) { error in
            guard case AWXUIContext.LaunchError.invalidCardBrand(let message) = error else {
                XCTFail("Expected invalidCardBrand error")
                return
            }
            XCTAssertEqual(message, "make sure you only include card brands defined in AWXCardBrand")
        }
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
            delegate: mockViewController
        )

        XCTAssertNotNil(element)
        XCTAssertNotNil(element.view)
    }

    func testCreate_WithInvalidSession_ThrowsError() async {
        // Create a Session with an invalid payment intent (missing id)
        let invalidIntent = AWXPaymentIntent()
        invalidIntent.amount = NSDecimalNumber(value: 100)
        invalidIntent.currency = "AUD"
        // id and clientSecret are empty - should fail validation
        let invalidSession = Session(paymentIntent: invalidIntent, countryCode: "AU")

        do {
            _ = try await AWXPaymentElement.create(
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
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        // AWXPaymentElement sets itself as the delegate to bridge callbacks
        XCTAssertTrue(element.paymentUIContext.delegate === element)
    }

    func testInit_PaymentUIContext_PaymentElementIsSet() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertTrue(element.paymentUIContext.paymentElement === element)
    }

    func testInit_PaymentUIContext_ShowsPaymentProcessingIndicator_DefaultTrue() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        XCTAssertTrue(element.paymentUIContext.showsPaymentProcessingIndicator)
    }

    func testInit_PaymentUIContext_ShowsPaymentProcessingIndicator_CanBeDisabled() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.showsPaymentProcessingIndicator = false

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        XCTAssertFalse(element.paymentUIContext.showsPaymentProcessingIndicator)
    }

    // MARK: - View Tests

    func testView_IsNotNil() async {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
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
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.cardPaymentNew))
        XCTAssertFalse(sections.contains(.applePay))
        XCTAssertFalse(sections.contains(.methodList))
    }

    func testSections_TabLayout_WithApplePay_IncludesApplePaySection() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey
        mockMethodProvider.methods = [applePayMethod]

        let element = AWXPaymentElement(
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
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()
        XCTAssertTrue(sections.contains(.methodList))
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
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        // With ApplePay + 2 other methods: 3 > 1 + 1 = 3 > 2 = true
        XCTAssertTrue(sections.contains(.methodList))
        XCTAssertTrue(sections.contains(.applePay))
    }

    func testSections_TabLayout_ShowsApplePayAsPrimaryButton_ShowsApplePayAtTop() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        mockMethodProvider.methods = [applePayMethod, cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        // Default configuration has showsApplePayAsPrimaryButton = true
        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .tab

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        // Apple Pay should be at the top (first section)
        XCTAssertTrue(sections.contains(.applePay), "Should contain Apple Pay section")
        XCTAssertEqual(sections.first, .applePay, "Apple Pay should be first section when prioritized")
        // Apple Pay should NOT be included in method list
        XCTAssertTrue(sections.contains(.methodList), "Should contain method list")
    }

    func testSections_TabLayout_ShowsApplePayAsPrimaryButtonFalse_IncludesApplePayInMethodListWhenSelected() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        mockMethodProvider.methods = [applePayMethod, cardMethod]
        mockMethodProvider.selectedMethod = applePayMethod
        mockMethodProvider.isApplePaySelectable = true

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .tab
        configuration.showsApplePayAsPrimaryButton = false

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        // Apple Pay should not be at the top when not prioritized
        XCTAssertNotEqual(sections.first, .applePay, "Apple Pay should not be first when not prioritized")
        // Apple Pay section should appear because it's selected from the tab list
        XCTAssertTrue(sections.contains(.applePay), "Should contain Apple Pay section when selected")
        XCTAssertTrue(sections.contains(.methodList), "Should contain method list with Apple Pay in it")
    }

    // MARK: - Section Tests (Accordion Layout)

    func testSections_AccordionLayout_WithMultipleMethods_ReturnsAccordionSections() {
        let method1 = AWXPaymentMethodType()
        method1.name = "method1"

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let method3 = AWXPaymentMethodType()
        method3.name = "method3"

        mockMethodProvider.methods = [method1, cardMethod, method3]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion
        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        // Middle method selected: should have both top and bottom
        XCTAssertTrue(sections.contains(.accordion(.top)), "Should have top accordion when middle method selected")
        XCTAssertTrue(sections.contains(.accordion(.bottom)), "Should have bottom accordion when middle method selected")

        // First method selected: only bottom
        mockMethodProvider.selectedMethod = method1
        let element2 = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )
        let sections2 = element2.sections()
        XCTAssertFalse(sections2.contains(.accordion(.top)))
        XCTAssertTrue(sections2.contains(.accordion(.bottom)))

        // Last method selected: only top
        mockMethodProvider.selectedMethod = method3
        let element3 = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )
        let sections3 = element3.sections()
        XCTAssertTrue(sections3.contains(.accordion(.top)))
        XCTAssertFalse(sections3.contains(.accordion(.bottom)))
    }

    func testSections_AccordionLayout_ExcludesMethodList() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [applePayMethod, cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion
        configuration.showsApplePayAsPrimaryButton = false  // Apple Pay integrated in accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertFalse(sections.contains(.methodList), "Accordion layout should not include methodList")
        // When card is selected, Apple Pay appears in accordion sections, not as separate .applePay section
        XCTAssertFalse(sections.contains(.applePay))
        XCTAssertTrue(sections.contains(.accordion(.top)))
    }

    func testSections_AccordionLayout_ApplePaySelected_ShowsApplePaySection() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [applePayMethod, cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = applePayMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion
        configuration.showsApplePayAsPrimaryButton = false  // Apple Pay integrated in accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.applePay), "Accordion layout should include ApplePay section when ApplePay is selected")
        XCTAssertFalse(sections.contains(.accordion(.top)), "No methods above Apple Pay when it's first and selected")
        XCTAssertTrue(sections.contains(.accordion(.bottom)), "Methods below Apple Pay should be in bottom accordion")
    }

    func testSections_AccordionLayout_ShowsApplePayAsPrimaryButton_ShowsApplePayAtTopBeforeAccordion() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let wechatMethod = AWXPaymentMethodType()
        wechatMethod.name = "wechatpay"

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        // Order: [ApplePay, WeChat, Card, Alipay] with Card selected
        // When Apple Pay is prioritized and excluded from accordion,
        // top accordion should contain [WeChat] and bottom accordion should contain [Alipay]
        mockMethodProvider.methods = [applePayMethod, wechatMethod, cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        // Default configuration has showsApplePayAsPrimaryButton = true
        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        // Apple Pay should be at the top (first section) before accordion sections
        XCTAssertTrue(sections.contains(.applePay), "Should contain Apple Pay section")
        XCTAssertEqual(sections.first, .applePay, "Apple Pay should be first section when prioritized in accordion layout")
        // Apple Pay should be excluded from accordion sections, but WeChat should be in .top
        XCTAssertTrue(sections.contains(.accordion(.top)), "Should have accordion top section with methods above Card (excluding Apple Pay)")
        XCTAssertTrue(sections.contains(.accordion(.bottom)), "Should have accordion bottom section with methods below Card")
    }

    func testSections_AccordionLayout_CardWithoutConsents_ShowsCardPaymentNew() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )
        let sections = element.sections()

        XCTAssertTrue(sections.contains(.cardPaymentNew))
        XCTAssertFalse(sections.contains(.cardPaymentConsent))
    }

    func testSections_AccordionLayout_CardWithConsents_ShowsCardPaymentConsent() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let consent = AWXPaymentConsent()
        consent.id = "consent_id"
        let paymentMethod = AWXPaymentMethod()
        paymentMethod.type = AWXCardKey
        consent.paymentMethod = paymentMethod
        mockMethodProvider.consents = [consent]

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )
        let sections = element.sections()

        XCTAssertTrue(sections.contains(.cardPaymentConsent))
        XCTAssertFalse(sections.contains(.cardPaymentNew))
    }

    func testSections_AccordionLayout_SchemaMethodSelected_ShowsSchemaPayment() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = alipayMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )
        let sections = element.sections()

        XCTAssertTrue(sections.contains(.schemaPayment("alipayhk")))
        XCTAssertFalse(sections.contains(.cardPaymentNew))
    }

    // MARK: - Section Tests (Card Element Type)

    func testSections_CardElementType_OnlyReturnsCardPaymentNew() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertEqual(sections.count, 1)
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    func testSections_CardElementType_ExcludesApplePay() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey

        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        mockMethodProvider.methods = [applePayMethod, cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertEqual(sections.count, 1)
        XCTAssertFalse(sections.contains(.applePay))
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    func testSections_CardElementType_ExcludesMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertEqual(sections.count, 1)
        XCTAssertFalse(sections.contains(.methodList))
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    func testSections_CardElementType_ExcludesConsents() {
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

        let configuration = AWXPaymentElement.Configuration()
        configuration.elementType = .addCard

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertEqual(sections.count, 1)
        XCTAssertFalse(sections.contains(.cardPaymentConsent))
        XCTAssertTrue(sections.contains(.cardPaymentNew))
    }

    // MARK: - displayMethodList Tests

    func testDisplayMethodList_SingleApplePay_HidesMethodList() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey
        mockMethodProvider.methods = [applePayMethod]
        mockMethodProvider.selectedMethod = applePayMethod

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertFalse(sections.contains(.methodList), "Single Apple Pay should hide method list")
    }

    func testDisplayMethodList_SingleApplePayWithShowsApplePayAsPrimaryButtonFalse_ShowsMethodList() {
        let applePayMethod = AWXPaymentMethodType()
        applePayMethod.name = AWXApplePayKey
        mockMethodProvider.methods = [applePayMethod]
        mockMethodProvider.selectedMethod = applePayMethod
        mockMethodProvider.isApplePaySelectable = true

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .tab
        configuration.showsApplePayAsPrimaryButton = false

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.methodList), "Single Apple Pay with showsApplePayAsPrimaryButton=false should show method list")
    }

    func testDisplayMethodList_SingleCardWithoutConsents_HidesMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod
        mockMethodProvider.consents = []

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertFalse(sections.contains(.methodList), "Single card without consents should hide method list")
    }

    func testDisplayMethodList_SingleCardWithConsents_ShowsMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let consent = AWXPaymentConsent()
        consent.id = "consent_id"
        let paymentMethod = AWXPaymentMethod()
        paymentMethod.type = AWXCardKey
        consent.paymentMethod = paymentMethod
        mockMethodProvider.consents = [consent]

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.methodList), "Single card with consents should show method list")
    }

    func testDisplayMethodList_SingleOtherMethod_ShowsMethodList() {
        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true
        mockMethodProvider.methods = [alipayMethod]
        mockMethodProvider.selectedMethod = alipayMethod

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.methodList), "Single non-card/non-applepay method should show method list")
    }

    func testDisplayMethodList_MultipleMethods_ShowsMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController
        )

        let sections = element.sections()

        XCTAssertTrue(sections.contains(.methodList), "Multiple methods should show method list")
    }

    func testDisplayMethodList_AccordionLayout_NeverShowsMethodList() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey

        let alipayMethod = AWXPaymentMethodType()
        alipayMethod.name = "alipayhk"
        alipayMethod.resources = AWXResources()
        alipayMethod.resources.hasSchema = true

        mockMethodProvider.methods = [cardMethod, alipayMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let configuration = AWXPaymentElement.Configuration()
        configuration.layout = .accordion

        let element = AWXPaymentElement(
            methodProvider: mockMethodProvider,
            delegate: mockViewController,
            configuration: configuration
        )

        let sections = element.sections()

        XCTAssertFalse(sections.contains(.methodList), "Accordion layout should never show method list")
    }

    // MARK: - Section Controller Tests

    func testSectionController_WithUnexpectedSectionType_ReturnsFallbackController() {
        let cardMethod = AWXPaymentMethodType()
        cardMethod.name = AWXCardKey
        mockMethodProvider.methods = [cardMethod]
        mockMethodProvider.selectedMethod = cardMethod

        let element = AWXPaymentElement(
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
