//
//  PaymentSessionHandlerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/19.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Core
import UIKit
import XCTest

@testable import Payment

class PaymentSessionHandlerTests: XCTestCase {

    private var mockPaymentResultDelegate: MockPaymentResultDelegate!
    private var mockViewController: UIViewController!
    private var mockSession: AWXSession!
    private var mockMethodType: AWXPaymentMethodType!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockPaymentResultDelegate = MockPaymentResultDelegate()
        mockViewController = UIViewController()
        mockSession = AWXSession()
        mockMethodType = AWXPaymentMethodType()
        mockMethodType.name = AWXCardKey
    }

    func testInit() throws {
        let methodType = AWXPaymentMethodType()
        methodType.name = AWXCardKey
        let session = AWXOneOffSession()
        let handler = PaymentSessionHandler(
            session: AWXOneOffSession(),
            viewController: mockViewController,
            paymentResultDelegate: mockPaymentResultDelegate,
            methodType: methodType
        )
        XCTAssertTrue(handler.paymentResultDelegate === mockPaymentResultDelegate)
        XCTAssertEqual(handler.viewController, mockViewController)
        XCTAssertEqual(handler.methodType, methodType)
        XCTAssertEqual(handler.session, session)
    }

    func testConvenienceInit() {
        let session = AWXOneOffSession()
        let handler = PaymentSessionHandler(
            session: session,
            viewController: mockPaymentResultDelegate
        )
        XCTAssertTrue(handler.paymentResultDelegate === mockPaymentResultDelegate)
        XCTAssertEqual(handler.viewController, mockPaymentResultDelegate)
        XCTAssertNil(handler.methodType)
        XCTAssertEqual(handler.session, session)
    }

    // test start apple pay check if it throws as expected
    func testStartApplePayAssertion() {
        let handler = PaymentSessionHandler(
            session: mockSession,
            viewController: mockPaymentResultDelegate,
            methodType: mockMethodType
        )

        XCTAssertThrowsError(
            try handler.startApplePay(), "Expected startApplePay to throw an error"
        ) { error in
            // Additional checks on the error can be performed here
//            XCTAssertEqual(
//                error as? PaymentSessionHandler.ValidationFailure,
//                PaymentSessionHandler.ValidationFailure("method type not matched"))
        }
        mockMethodType.name = AWXApplePayKey
        XCTAssertThrowsError(try handler.startApplePay())
        //        mockMethodType
    }
}
