import AirwallexCore
@testable import AirwallexPayment
import UIKit
import XCTest
import PassKit

class ApplePayProviderTests: XCTestCase {
    
    private var mockPaymentIntent: AWXPaymentIntent!
    private var mockSession: Session!
    private var mockApiClient: AWXAPIClient!
    
    override func setUp() {
        super.setUp()
        // Reset mock controller state before each test
        MockPKPaymentAuthorizationController.reset()
        
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        paymentIntent.amount = NSDecimalNumber(string: "10.00")
        paymentIntent.currency = "USD"
        paymentIntent.clientSecret = "mock_client_secret"
        mockPaymentIntent = paymentIntent
        
        let applePayOptions = AWXApplePayOptions(merchantIdentifier: "merchant.com.test")
        let session = Session(
            countryCode: "US",
            paymentIntent: mockPaymentIntent,
            returnURL: "https://example.com",
            applePayOptions: applePayOptions
        )
        mockSession = session
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let clientConfiguration = AWXAPIClientConfiguration()
        clientConfiguration.sessionConfiguration = sessionConfiguration
        mockApiClient = AWXAPIClient(configuration: clientConfiguration)
    }
    
    override func tearDown() {
        // Clean up after each test
        super.tearDown()
        MockURLProtocol.resetMockResponses()
    }
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Test that properties are correctly initialized
        let delegate = MockProviderDelegate()
        
        // Create a proper Session with required properties
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Use the MockPKPaymentAuthorizationController
        let mockController = MockPKPaymentAuthorizationController.self
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            paymentController: mockController
        )
        
        // Verify the provider was initialized correctly
        XCTAssertTrue(provider.delegate === delegate)
        XCTAssertEqual(provider.paymentMethodType, methodType)
    }
    
    // MARK: - canHandle Static Method Tests
    
    func testCanHandleWithValidSession() {
        // Test with valid session and payment method type
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        XCTAssertTrue(ApplePayProvider.canHandle(mockSession, paymentMethod: methodType))
    }
    
    func testCanHandleWithInvalidSession() {
        // Test with invalid session types
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Test with AWXOneOffSession
        let oneOffSession = AWXOneOffSession()
        oneOffSession.paymentIntent = mockPaymentIntent
        XCTAssertFalse(ApplePayProvider.canHandle(oneOffSession, paymentMethod: methodType))
        
        // Test with AWXRecurringSession
        let recurringSession = AWXRecurringSession()
        XCTAssertFalse(ApplePayProvider.canHandle(recurringSession, paymentMethod: methodType))
        
        // Test with AWXRecurringWithIntentSession
        let recurringWithIntentSession = AWXRecurringWithIntentSession()
        recurringWithIntentSession.paymentIntent = mockPaymentIntent
        XCTAssertFalse(ApplePayProvider.canHandle(recurringWithIntentSession, paymentMethod: methodType))
    }
    
    // MARK: - Payment status handling
    
    func testStartPaymentWithMissingApplePayOptions() {
        // Test with missing Apple Pay options
        let delegate = MockProviderDelegate()
        
        // No Apple Pay options set
        mockSession.applePayOptions = nil
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        XCTAssertThrowsError(try provider.startPayment()) { error in
            XCTAssertTrue(error is AWXApplePayProvider.ValidationError)
        }
    }
    
    func testStartPaymentPresentation() async {
        // Test successful presentation using mocks and dependency injection
        let delegate = MockProviderDelegate()
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Reset mock controller state
        MockPKPaymentAuthorizationController.reset()
        MockPKPaymentAuthorizationController.shouldSucceedPresentation = true
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        try? provider.startPayment()
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify controller was created with the right request
        XCTAssertNotNil(MockPKPaymentAuthorizationController.lastInstance?.lastRequest)
        XCTAssertEqual(MockPKPaymentAuthorizationController.lastInstance?.presentCalled, true)
        
        // Verify payment state
        XCTAssertEqual(provider.paymentState, .notStarted)
        
        // Verify delegate methods called
        XCTAssertTrue(delegate.didStartRequest == 1)
    }
    
    func testStartPaymentPresentationFailure() async {
        // Test presentation failure
        let delegate = MockProviderDelegate()
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Reset mock controller state and configure for failure
        MockPKPaymentAuthorizationController.reset()
        MockPKPaymentAuthorizationController.shouldSucceedPresentation = false
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        try? provider.startPayment()
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify controller was created but presentation failed
        XCTAssertNotNil(MockPKPaymentAuthorizationController.lastInstance?.lastRequest)
        XCTAssertEqual(MockPKPaymentAuthorizationController.lastInstance?.presentCalled, true)
        
        // Verify delegate methods called with appropriate error
        XCTAssertEqual(delegate.didStartRequest, 0)
        XCTAssertEqual(delegate.didEndRequest, 0)
        XCTAssertNotNil(delegate.completionError)
        
        // Verify payment state
        XCTAssertEqual(provider.paymentState, .notPresented)
    }
    
    func testDidAuthorizePaymentSuccess() async {
        // Test successful payment authorization
        let delegate = MockProviderDelegate()
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Reset mock controller
        MockPKPaymentAuthorizationController.reset()
        MockPKPaymentAuthorizationController.shouldSucceedPresentation = true
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        XCTAssertEqual(provider.paymentState, .notPresented)
        
        // Start payment to initialize controller
        try? provider.startPayment()
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(provider.paymentState, .notStarted)
        
        // Verify the presentation was called
        guard let controller = MockPKPaymentAuthorizationController.lastInstance else {
            assert(false)
            return
        }
        XCTAssertNotNil(controller.lastRequest)
        XCTAssertEqual(controller.presentCalled, true)
        
        // Create mock payment
        let mockPayment = MockPKPayment()
        
        // Simulate successful authorization
//        await provider.paymentAuthorizationController(controller, didAuthorizePayment: mockPayment, handler: { _ in})
        MockURLProtocol.mockSuccess()
        _ = await provider.confirmIntent(payment: mockPayment)
        await provider.paymentAuthorizationControllerDidFinish(controller)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify authorization result
        XCTAssertEqual(delegate.completionStatus, .success)
        XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
        XCTAssertEqual(provider.paymentState, .complete)
    }
    
    func testDidAuthorizePaymentFailure() async {
        // Test failed payment authorization
        let delegate = MockProviderDelegate()
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Reset mock controller
        MockPKPaymentAuthorizationController.reset()
        MockPKPaymentAuthorizationController.shouldSucceedPresentation = true
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        XCTAssertEqual(provider.paymentState, .notPresented)
        
        // Start payment to initialize controller
        try? provider.startPayment()
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(provider.paymentState, .notStarted)
        
        // Verify the presentation was called
        guard let controller = MockPKPaymentAuthorizationController.lastInstance else {
            assert(false)
            return
        }
        XCTAssertNotNil(controller.lastRequest)
        XCTAssertEqual(controller.presentCalled, true)
        
        // Create mock payment with token
        let mockToken = MockPKPaymentToken()
        let mockPayment = MockPKPayment(token: mockToken)
        
        // Simulate failed authorization by mocking a failure response
        MockURLProtocol.mockFailure()
        _ = await provider.confirmIntent(payment: mockPayment)
        await provider.paymentAuthorizationControllerDidFinish(controller)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify authorization result
        XCTAssertEqual(delegate.completionStatus, .failure)
        XCTAssertNotNil(delegate.completionError)
        XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
        XCTAssertEqual(provider.paymentState, .complete)
    }
    
    func testCancelledPayment() async {
        // Test cancelled payment flow
        let delegate = MockProviderDelegate()
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Reset mock controller
        MockPKPaymentAuthorizationController.reset()
        MockPKPaymentAuthorizationController.shouldSucceedPresentation = true
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        XCTAssertEqual(provider.paymentState, .notPresented)
        
        // Start payment to initialize controller
        try? provider.startPayment(cancelPaymentOnDismiss: true)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(provider.paymentState, .notStarted)
        
        guard let controller = MockPKPaymentAuthorizationController.lastInstance else {
            XCTFail("Controller not created")
            return
        }
        
        // Verify the controller was created properly
        XCTAssertNotNil(controller.lastRequest)
        XCTAssertEqual(controller.presentCalled, true)
        
        // Simulate user cancelling Apple Pay sheet without authorization
        // by directly calling the completion method
        await provider.paymentAuthorizationControllerDidFinish(controller)
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify the state after cancellation
        XCTAssertTrue(controller.dismissCalled)
        XCTAssertEqual(delegate.completionStatus, .cancel)
        XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
    }
    
    func testPaymentSheetDismissedInPendingStatus() async {
        // Test payment behavior with slow network response
        let delegate = MockProviderDelegate()
        
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXApplePayKey
        
        // Reset mock controller
        MockPKPaymentAuthorizationController.reset()
        MockPKPaymentAuthorizationController.shouldSucceedPresentation = true
        
        let provider = ApplePayProvider(
            delegate: delegate,
            session: mockSession,
            methodType: methodType,
            apiClient: mockApiClient,
            paymentController: MockPKPaymentAuthorizationController.self
        )
        
        XCTAssertEqual(provider.paymentState, .notPresented)
        
        // Start payment to initialize controller
        try? provider.startPayment()
        
        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(provider.paymentState, .notStarted)
        
        // Verify the presentation was called
        guard let controller = MockPKPaymentAuthorizationController.lastInstance else {
            XCTFail("Controller not created")
            return
        }
        
        // Create mock payment with token
        let mockPayment = MockPKPayment()
        
        // Simulate slow network response (3 seconds)
        MockURLProtocol.mockSlowResponse(delay: 500_000_000)
        
        // Start the payment confirmation
        async let foo = provider.confirmIntent(payment: mockPayment)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(provider.paymentState, .pending)
        // User completes the payment while network request is still in progress
        await provider.paymentAuthorizationControllerDidFinish(controller)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify the controller was dismissed
        XCTAssertTrue(controller.dismissCalled)
        
        // Verify the state during network request
        XCTAssertEqual(delegate.completionStatus, .inProgress)
        
        // Wait for the slow network response to complete
        _ = await foo
        
        // Verify final state after network request completes
        XCTAssertEqual(delegate.completionStatus, .success)
        XCTAssertEqual(delegate.didStartRequest, delegate.didEndRequest)
        XCTAssertEqual(provider.paymentState, .complete)
    }
}
