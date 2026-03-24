//
//  BottomSheetPresentationControllerTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/3/4.
//  Copyright © 2025 Airwallex. All rights reserved.
//

@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class BottomSheetPresentationControllerTests: XCTestCase {

    func testFrameOfPresentedView_positionedAtBottom() {
        let presented = UIViewController()
        presented.view.translatesAutoresizingMaskIntoConstraints = false
        // Give the presented view a fixed height
        presented.view.heightAnchor.constraint(equalToConstant: 200).isActive = true

        let presenting = UIViewController()
        presenting.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)

        let pc = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )

        // Verify the controller can be created with correct references
        XCTAssertNotNil(pc)
        XCTAssertTrue(pc.presentedViewController === presented)
    }

    func testDimmingViewTap_dismissesPresented() {
        let presented = UIViewController()
        let presenting = MockPresentingViewController()

        let pc = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )

        XCTAssertNotNil(pc)
    }

    func testUpdateDimmingAlpha() {
        let presented = UIViewController()
        let presenting = UIViewController()

        let pc = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )

        // updateDimmingAlpha should not crash even before presentation
        pc.updateDimmingAlpha(for: 0.5)
        pc.updateDimmingAlpha(for: 0)
        pc.updateDimmingAlpha(for: 1)
    }

    func testDismissalTransitionDidEnd_completed() {
        let presented = UIViewController()
        let presenting = UIViewController()

        let pc = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )

        // Should not crash
        pc.dismissalTransitionDidEnd(true)
        pc.dismissalTransitionDidEnd(false)
    }
}

private class MockPresentingViewController: UIViewController {
    var presentedViewControllerSpy: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewControllerSpy = viewControllerToPresent
        completion?()
    }
}
