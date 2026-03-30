import AirwallexCore
@testable import AirwallexPayment
import PassKit
import UIKit
import XCTest

class ApplePayProviderTests: XCTestCase {

    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockSession: Session!
    private var mockApiClient: AWXAPIClient!
    private var mockFactory: MockPaymentAuthorizationControllerFactory!

    override func setUp() {
        super.setUp()
        mockFactory = MockPaymentAuthorizationControllerFactory()

        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        paymentIntent.amount = NSDecimalNumber(string: "10.00")
        paymentIntent.currency = "USD"
        paymentIntent.clientSecret = "mock_client_secret"
        mockPaymentIntent = paymentIntent

        let applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant.com.test")
        let session = Session(
            paymentIntent: mockPaymentIntent,
            countryCode: "US",
            applePayOptions: applePayOptions,
            returnURL: "https://example.com"
        )
        mockSession = session

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockApiClient = AWXAPIClient(configuration: clientConfiguration)
    }

    override func tearDown() {
        super.tearDown()
        MockURLProtocol.resetMockResponses()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        let delegate = MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            controllerFactory: mockFactory
        )

        XCTAssertTrue(provider.delegate === delegate)
        XCTAssertEqual(provider.paymentMethodType, methodType)
    }

    // MARK: - canHandle Static Method Tests

    func testCanHandleWithValidSession() {
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        XCTAssertTrue(ApplePayProvider.canHandle(mockSession, paymentMethod: methodType))
    }

    func testCanHandleWithInvalidSession() {
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        let oneOffSession = AWXOneOffSession()
        oneOffSession.paymentIntent = mockPaymentIntent
        XCTAssertFalse(ApplePayProvider.canHandle(oneOffSession, paymentMethod: methodType))

        let recurringSession = AWXRecurringSession()
        XCTAssertFalse(ApplePayProvider.canHandle(recurringSession, paymentMethod: methodType))

        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        XCTAssertFalse(ApplePayProvider.canHandle(recurringWithIntentSession, paymentMethod: methodType))
    }

    // MARK: - Payment status handling

    func testStartPaymentWithMissingApplePayOptions() {
        let delegate = MockProviderDelegate()

        mockSession.applePayOptions = nil

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            controllerFactory: mockFactory
        )

        XCTAssertThrowsError(try provider.startPayment()) { error in
            XCTAssertTrue(error is AWXApplePayProvider.ValidationError)
        }
    }

    func testStartPaymentPresentation() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = true

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            controllerFactory: mockFactory
        )

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertNotNil(mockFactory.lastRequest)
        XCTAssertEqual(mockFactory.lastController?.presentCalled, true)

        XCTAssertEqual(provider.paymentState, .notStarted)

        await MainActor.run {
            XCTAssertTrue(delegate.didStartRequest == 1)
        }
    }

    func testStartPaymentPresentationFailure() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = false

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            controllerFactory: mockFactory
        )

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertNotNil(mockFactory.lastRequest)
        XCTAssertEqual(mockFactory.lastController?.presentCalled, true)

        await MainActor.run {
            XCTAssertEqual(delegate.didStartRequest, 1)
            XCTAssertEqual(delegate.didEndRequest, 0)
            XCTAssertNotNil(delegate.completionError)

            XCTAssertEqual(provider.paymentState, .notPresented)
        }
    }

    func testDidAuthorizePaymentSuccess() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = true

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            controllerFactory: mockFactory
        )

        XCTAssertEqual(provider.paymentState, .notPresented)

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(provider.paymentState, .notStarted)

        guard let controller = mockFactory.lastController else {
            XCTFail("Controller not created")
            return
        }
        XCTAssertNotNil(mockFactory.lastRequest)
        XCTAssertEqual(controller.presentCalled, true)

        let mockPayment = MockPKPayment()

        MockURLProtocol.mockSuccess()
        _ = await provider.confirmIntent(payment: mockPayment)
        provider.handleControllerDidFinish()

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            XCTAssertEqual(delegate.completionStatus, .success)
            XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
            XCTAssertEqual(provider.paymentState, .complete)
        }
    }

    func testDidAuthorizePaymentFailure() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = true

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            controllerFactory: mockFactory
        )

        XCTAssertEqual(provider.paymentState, .notPresented)

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(provider.paymentState, .notStarted)

        guard let controller = mockFactory.lastController else {
            XCTFail("Controller not created")
            return
        }
        XCTAssertNotNil(mockFactory.lastRequest)
        XCTAssertEqual(controller.presentCalled, true)

        let mockToken = MockPKPaymentToken()
        let mockPayment = MockPKPayment(token: mockToken)

        MockURLProtocol.mockFailure()
        _ = await provider.confirmIntent(payment: mockPayment)
        provider.handleControllerDidFinish()

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            XCTAssertEqual(delegate.completionStatus, .failure)
            XCTAssertNotNil(delegate.completionError)
            XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
            XCTAssertEqual(provider.paymentState, .complete)
        }
    }

    func testCancelledPayment() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = true

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            controllerFactory: mockFactory
        )

        XCTAssertEqual(provider.paymentState, .notPresented)

        try? provider.startPayment(cancelPaymentOnDismiss: true)

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(provider.paymentState, .notStarted)

        guard let controller = mockFactory.lastController else {
            XCTFail("Controller not created")
            return
        }

        XCTAssertNotNil(mockFactory.lastRequest)
        XCTAssertEqual(controller.presentCalled, true)

        provider.handleControllerDidFinish()

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(controller.dismissCalled)
        await MainActor.run {
            XCTAssertEqual(delegate.completionStatus, .cancel)
            XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
        }
    }

    func testPaymentSheetDismissedInPendingStatus() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = true

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            controllerFactory: mockFactory
        )

        XCTAssertEqual(provider.paymentState, .notPresented)

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(provider.paymentState, .notStarted)

        guard let controller = mockFactory.lastController else {
            XCTFail("Controller not created")
            return
        }

        let mockPayment = MockPKPayment()

        MockURLProtocol.mockSlowResponse(delay: 1_000_000_000)

        async let foo = provider.confirmIntent(payment: mockPayment)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(provider.paymentState, .pending)
        provider.handleControllerDidFinish()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(controller.dismissCalled)

        await MainActor.run {
            XCTAssertEqual(delegate.completionStatus, .inProgress)
        }

        _ = await foo

        await MainActor.run {
            XCTAssertEqual(delegate.completionStatus, .success)
            XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
            XCTAssertEqual(provider.paymentState, .complete)
        }
    }

    // MARK: - presentationWindow Tests

    func testStartPaymentFailsWhenViewControllerInitializationFails() async {
        let delegate = await MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockSession.applePayOptions?.supportedNetworks = []

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            controllerFactory: mockFactory
        )

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            XCTAssertEqual(delegate.completionStatus, .failure)
            XCTAssertNotNil(delegate.completionError)
            XCTAssertEqual(delegate.completionError?.localizedDescription, "Failed to initialize Apple Pay Controller.")
        }
    }

    @MainActor
    func testPresentationWindowReturnsWindow() async {
        let delegate = MockProviderDelegate()

        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey

        mockFactory.shouldSucceedPresentation = true

        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            controllerFactory: mockFactory
        )

        try? provider.startPayment()

        try? await Task.sleep(nanoseconds: 500_000_000)

        guard mockFactory.lastController != nil else {
            XCTFail("Controller not created")
            return
        }

        // presentationWindow requires a real PKPaymentAuthorizationController parameter,
        // but we can verify it doesn't crash by passing a dummy instance
        let dummyRequest = PKPaymentRequest()
        dummyRequest.merchantIdentifier = "merchant.com.test"
        dummyRequest.countryCode = "US"
        dummyRequest.currencyCode = "USD"
        dummyRequest.supportedNetworks = [.visa]
        dummyRequest.merchantCapabilities = .threeDSecure
        dummyRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Test", amount: NSDecimalNumber(string: "10.00"))
        ]
        let dummyController = PKPaymentAuthorizationController(paymentRequest: dummyRequest)

        let window = provider.presentationWindow(for: dummyController)

        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            XCTAssertEqual(window, keyWindow)
        } else {
            XCTAssertNil(window)
        }
    }
}
