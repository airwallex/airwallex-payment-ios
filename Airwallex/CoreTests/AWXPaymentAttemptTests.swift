//
//  AWXPaymentAttemptTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import XCTest

@testable import Core

class AWXPaymentAttemptTests: XCTestCase {
    // Test if the initialization of AWXPaymentAttempt assigns values correctly.
    func testInitialization() {
        let paymentMethod = AWXPaymentMethod()
        let authenticationData = AWXAuthenticationData()
        let attempt = AWXPaymentAttempt()

        let mirror = Mirror(reflecting: attempt)
        if let amount = mirror.descendant("amount") as? Double {
            XCTAssertNil(amount)
        }

        if let capturedAmount = mirror.descendant("capturedAmount") as? Double {
            XCTAssertNil(capturedAmount)
        }

        if let refundedAmount = mirror.descendant("refundedAmount") as? Double {
            XCTAssertNil(refundedAmount)
        }

        attempt.setValue("123", forKey: "Id")
        attempt.setAmount(100.0)
        attempt.setValue(paymentMethod, forKey: "paymentMethod")
        attempt.setValue("succeeded", forKey: "status")
        attempt.setCapturedAmount(90.0)
        attempt.setRefundedAmount(10.0)
        attempt.setValue(authenticationData, forKey: "authenticationData")

        XCTAssertEqual(attempt.Id, "123")
        XCTAssertEqual(attempt.objcAmount, 100.0)
        XCTAssertEqual(attempt.paymentMethod, paymentMethod)
        XCTAssertEqual(attempt.status, "succeeded")
        XCTAssertEqual(attempt.capturedAmount, 90.0)
        XCTAssertEqual(attempt.refundedAmount, 10.0)
        XCTAssertEqual(attempt.authenticationData, authenticationData)
    }

    // Test JSON decoding
    func testJSONDecoding() {
        let json = """
        {
            "id": "123",
            "amount": 100.0,
            "payment_method": {},
            "status": "succeeded",
            "captured_amount": 90.0,
            "refunded_amount": 10.0,
            "authentication_data": {}
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let attempt = try decoder.decode(AWXPaymentAttempt.self, from: json)
            XCTAssertEqual(attempt.Id, "123")
            XCTAssertEqual(attempt.amount, 100.0)
            XCTAssertNotNil(attempt.paymentMethod)
            XCTAssertEqual(attempt.status, "succeeded")
            XCTAssertEqual(attempt.capturedAmount, 90.0)
            XCTAssertEqual(attempt.refundedAmount, 10.0)
            XCTAssertNotNil(attempt.authenticationData)
        } catch {
            XCTFail("Decoding failed with error: \(error)")
        }
    }

    // Test NSNumber properties
    func testNSNumberConversion() {
        let attempt = AWXPaymentAttempt()
        attempt.setAmount(100.0)
        attempt.setCapturedAmount(90.0)
        attempt.setRefundedAmount(10.0)

        XCTAssertEqual(attempt.objcAmount, 100.0)
        XCTAssertEqual(attempt.objcCapturedAmount, 90.0)
        XCTAssertEqual(attempt.objcRefundedAmount, 10.0)
    }
}
