//
//  BottomSheetAnimatorTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/3/4.
//  Copyright © 2025 Airwallex. All rights reserved.
//

@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class BottomSheetAnimatorTests: XCTestCase {

    func testTransitionDuration() {
        let presentAnimator = BottomSheetAnimator(isPresenting: true)
        let dismissAnimator = BottomSheetAnimator(isPresenting: false)

        XCTAssertEqual(presentAnimator.transitionDuration(using: nil), 0.25)
        XCTAssertEqual(dismissAnimator.transitionDuration(using: nil), 0.25)
    }

    func testIsPresenting() {
        let presentAnimator = BottomSheetAnimator(isPresenting: true)
        let dismissAnimator = BottomSheetAnimator(isPresenting: false)

        XCTAssertTrue(presentAnimator.isPresenting)
        XCTAssertFalse(dismissAnimator.isPresenting)
    }
}
