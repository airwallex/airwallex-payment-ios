//
//  PaymentUIContextTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
import UIKit
import XCTest

@MainActor
final class PaymentUIContextTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInit_SetsAllProperties() {
        let viewController = UIViewController()
        let delegate = MockPaymentResultDelegate()
        var dismissActionCalled = false
        let dismissAction: PaymentUIContext.DismissActionBlock = { completion in
            dismissActionCalled = true
            completion()
        }

        let context = PaymentUIContext(
            viewController: viewController,
            delegate: delegate,
            dismissAction: dismissAction
        )

        XCTAssertTrue(context.viewController === viewController)
        XCTAssertTrue(context.delegate === delegate)
        XCTAssertNotNil(context.dismissAction)

        // Verify dismissAction is correctly set
        context.dismissAction? {}
        XCTAssertTrue(dismissActionCalled)
    }

    func testInit_WithDefaultValues() {
        let context = PaymentUIContext()

        XCTAssertNil(context.viewController)
        XCTAssertNil(context.delegate)
        XCTAssertNil(context.dismissAction)
    }

    // MARK: - Dismiss Tests

    func testDismiss_WithDismissAction_CallsAction() {
        var dismissActionCalled = false
        let dismissAction: PaymentUIContext.DismissActionBlock = { completion in
            dismissActionCalled = true
            completion()
        }

        let context = PaymentUIContext(dismissAction: dismissAction)

        var completionCalled = false
        context.dismiss {
            completionCalled = true
        }

        XCTAssertTrue(dismissActionCalled)
        XCTAssertTrue(completionCalled)
    }

    func testDismiss_WithoutDismissAction_CallsCompletionDirectly() {
        let context = PaymentUIContext()

        var completionCalled = false
        context.dismiss {
            completionCalled = true
        }

        XCTAssertTrue(completionCalled)
    }

    func testDismiss_ClearsDismissActionAfterCalling() {
        let dismissAction: PaymentUIContext.DismissActionBlock = { completion in
            completion()
        }

        let context = PaymentUIContext(dismissAction: dismissAction)
        XCTAssertNotNil(context.dismissAction)

        context.dismiss(completion: nil)

        XCTAssertNil(context.dismissAction)
    }

    func testDismiss_WithNilCompletion_DoesNotCrash() {
        let dismissAction: PaymentUIContext.DismissActionBlock = { completion in
            completion()
        }

        let context = PaymentUIContext(dismissAction: dismissAction)

        // Should not crash
        context.dismiss(completion: nil)
    }
}
