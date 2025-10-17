import PassKit
import Foundation
import UIKit

// This class serves as a drop-in replacement for PKPaymentAuthorizationController
// in test environments. It conforms to PKPaymentAuthorizationController.Type through
// protocol extensions and typealias.
class MockPKPaymentAuthorizationController: PKPaymentAuthorizationController {
    // Static properties
    static var shouldSucceedPresentation = true
    static var lastInstance: MockPKPaymentAuthorizationController?
    
    var lastRequest: PKPaymentRequest?
    var presentCalled = false
    var dismissCalled = false
    
    // Static methods
    static func reset() {
        shouldSucceedPresentation = true
        lastInstance = nil
    }
    
    // Factory method to match PKPaymentAuthorizationController's init
    static func `init`(paymentRequest: PKPaymentRequest) -> MockPKPaymentAuthorizationController {
        return MockPKPaymentAuthorizationController(paymentRequest: paymentRequest)
    }
    
    // Type methods required by PKPaymentAuthorizationController.Type
    override static func canMakePayments() -> Bool {
        return true
    }
    
    override static func canMakePayments(usingNetworks supportedNetworks: [PKPaymentNetwork]) -> Bool {
        return true
    }
    
    override static func canMakePayments(usingNetworks supportedNetworks: [PKPaymentNetwork], capabilities: PKMerchantCapability) -> Bool {
        return true
    }
    
    override init(paymentRequest: PKPaymentRequest) {
        super.init(paymentRequest: paymentRequest)
        lastRequest = paymentRequest
        MockPKPaymentAuthorizationController.lastInstance = self
    }
    
    override func present() async -> Bool {
        presentCalled = true
        return MockPKPaymentAuthorizationController.shouldSucceedPresentation
    }
    
    override func dismiss() async {
        dismissCalled = true
    }
}
