import PassKit
import Foundation
import UIKit

// This class defines a mock for PKPayment that can be used in tests
class MockPKPayment: PKPayment {
    
    // Private properties to hold mock data
    private let _token: MockPKPaymentToken
    
    // Overrides to return mock data
    override var token: PKPaymentToken {
        return _token
    }
    
    // Custom initializer for test configuration
    init(token: MockPKPaymentToken = MockPKPaymentToken()) {
        self._token = token
        super.init()
    }
}

// Mock implementation of PKPaymentToken
class MockPKPaymentToken: PKPaymentToken {
    
    override var paymentMethod: PKPaymentMethod {
        _paymentMethod
    }
    
    private let _paymentMethod = MockPKPaymentMethod()
    
    // Private properties to hold mock data
    private let _payloadResult: [String: Any] = [
        "card_brand": "card_brand",
        "card_type": "card_type",
        "data": "data",
        "header": [
            "ephemeralPublicKey": "ephemeralPublicKey",
            "publicKeyHash": "publicKeyHash",
            "transactionId": "transactionId"
        ],
        "signature": "signature",
        "version": "version"
    ]
    
    override var paymentData: Data {
        try! JSONSerialization.data(withJSONObject: _payloadResult)
    }
}

class MockPKPaymentMethod: PKPaymentMethod {
    override var network: PKPaymentNetwork? {
        .visa
    }
}
