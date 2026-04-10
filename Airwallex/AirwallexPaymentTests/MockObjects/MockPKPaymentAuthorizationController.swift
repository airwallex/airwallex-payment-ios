@testable import AirwallexPayment
import PassKit

class MockPaymentAuthorizationController: PaymentAuthorizationControlling {
    var delegate: PKPaymentAuthorizationControllerDelegate?
    var presentCalled = false
    var dismissCalled = false
    var shouldSucceedPresentation = true

    func present() async -> Bool {
        presentCalled = true
        return shouldSucceedPresentation
    }

    func dismiss() async {
        dismissCalled = true
    }
}

class MockPaymentAuthorizationControllerFactory: PaymentAuthorizationControllerFactory {
    var lastController: MockPaymentAuthorizationController?
    var shouldSucceedPresentation = true
    var lastRequest: PKPaymentRequest?

    func makeController(paymentRequest: PKPaymentRequest) -> PaymentAuthorizationControlling {
        let controller = MockPaymentAuthorizationController()
        controller.shouldSucceedPresentation = shouldSucceedPresentation
        lastController = controller
        lastRequest = paymentRequest
        return controller
    }
}
