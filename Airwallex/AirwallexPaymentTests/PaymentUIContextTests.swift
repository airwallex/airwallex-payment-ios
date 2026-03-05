//
//  PaymentUIContextTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/1/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable import AirwallexPayment
import UIKit
import XCTest

@MainActor
final class PaymentUIContextTests: XCTestCase {

    func testCompletePaymentSession_DoesNotCrash() async {
        let context = PaymentUIContext()
        await context.completePaymentSession()
    }
}
