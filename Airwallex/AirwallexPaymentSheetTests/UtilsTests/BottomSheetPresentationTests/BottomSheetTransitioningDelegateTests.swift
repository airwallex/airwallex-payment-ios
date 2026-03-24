//
//  BottomSheetTransitioningDelegateTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/3/4.
//  Copyright © 2025 Airwallex. All rights reserved.
//

@testable import AirwallexPaymentSheet
import UIKit
import XCTest

class BottomSheetTransitioningDelegateTests: XCTestCase {

    func testPresentationController_returnsBottomSheetPresentationController() {
        let vc = UIViewController()
        _ = vc.view
        let interactiveDismiss = BottomSheetInteractiveDismissTransition(presentedViewController: vc)
        let delegate = BottomSheetTransitioningDelegate(interactiveDismiss: interactiveDismiss)

        let presented = UIViewController()
        let presenting = UIViewController()

        let pc = delegate.presentationController(
            forPresented: presented,
            presenting: presenting,
            source: presenting
        )

        XCTAssertNotNil(pc)
        XCTAssertTrue(pc is BottomSheetPresentationController)
    }

    func testAnimationControllerForPresented_returnsPresenter() {
        let vc = UIViewController()
        _ = vc.view
        let interactiveDismiss = BottomSheetInteractiveDismissTransition(presentedViewController: vc)
        let delegate = BottomSheetTransitioningDelegate(interactiveDismiss: interactiveDismiss)

        let presented = UIViewController()
        let presenting = UIViewController()

        let animator = delegate.animationController(
            forPresented: presented,
            presenting: presenting,
            source: presenting
        )

        XCTAssertNotNil(animator)
        XCTAssertTrue((animator as? BottomSheetAnimator)?.isPresenting == true)
    }

    func testAnimationControllerForDismissed_returnsDismisser() {
        let vc = UIViewController()
        _ = vc.view
        let interactiveDismiss = BottomSheetInteractiveDismissTransition(presentedViewController: vc)
        let delegate = BottomSheetTransitioningDelegate(interactiveDismiss: interactiveDismiss)

        let dismissed = UIViewController()
        let animator = delegate.animationController(forDismissed: dismissed)

        XCTAssertNotNil(animator)
        XCTAssertTrue((animator as? BottomSheetAnimator)?.isPresenting == false)
    }

    func testInteractionControllerForDismissal_returnsNilWhenNotInteracting() {
        let vc = UIViewController()
        _ = vc.view
        let interactiveDismiss = BottomSheetInteractiveDismissTransition(presentedViewController: vc)
        let delegate = BottomSheetTransitioningDelegate(interactiveDismiss: interactiveDismiss)

        let animator = BottomSheetAnimator(isPresenting: false)
        let controller = delegate.interactionControllerForDismissal(using: animator)

        XCTAssertNil(controller, "Should return nil when not interacting")
    }
}
