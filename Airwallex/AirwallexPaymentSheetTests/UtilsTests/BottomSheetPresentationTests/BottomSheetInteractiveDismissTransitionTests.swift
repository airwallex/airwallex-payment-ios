//
//  BottomSheetInteractiveDismissTransitionTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/3/4.
//  Copyright © 2025 Airwallex. All rights reserved.
//

@testable import AirwallexPaymentSheet
import UIKit
import XCTest

// swiftlint:disable:next type_name
class BottomSheetInteractiveDismissTransitionTests: XCTestCase {

    func testInitialState() {
        let vc = UIViewController()
        _ = vc.view // load view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        XCTAssertFalse(transition.isInteracting)
    }

    func testPanGestureAddedToView() {
        let vc = UIViewController()
        _ = vc.view // load view

        let gestureCountBefore = vc.view.gestureRecognizers?.count ?? 0
        _ = BottomSheetInteractiveDismissTransition(presentedViewController: vc)
        let gestureCountAfter = vc.view.gestureRecognizers?.count ?? 0

        XCTAssertEqual(gestureCountAfter, gestureCountBefore + 1)
    }

    func testPanGestureIsUIPanGestureRecognizer() {
        let vc = UIViewController()
        _ = vc.view
        _ = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let panGestures = vc.view.gestureRecognizers?.compactMap { $0 as? UIPanGestureRecognizer } ?? []
        XCTAssertFalse(panGestures.isEmpty)
    }

    func testConfigurePresentationController() {
        let presented = UIViewController()
        _ = presented.view
        let presenting = UIViewController()

        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: presented)
        let pc = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )

        // Should not crash
        transition.configure(presentationController: pc)
    }

    func testGestureRecognizerShouldBegin_nonPanGesture_returnsTrue() {
        let vc = UIViewController()
        _ = vc.view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let tapGesture = UITapGestureRecognizer()
        XCTAssertTrue(transition.gestureRecognizerShouldBegin(tapGesture))
    }

    func testGestureRecognizerShouldBegin_upwardDrag_returnsFalse() {
        let vc = UIViewController()
        _ = vc.view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let pan = MockPanGestureRecognizer()
        pan.mockVelocity = CGPoint(x: 0, y: -100) // upward
        XCTAssertFalse(transition.gestureRecognizerShouldBegin(pan))
    }

    func testGestureRecognizerShouldBegin_downwardDrag_noScrollView_returnsTrue() {
        let vc = UIViewController()
        _ = vc.view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let pan = MockPanGestureRecognizer()
        pan.mockVelocity = CGPoint(x: 0, y: 100) // downward
        XCTAssertTrue(transition.gestureRecognizerShouldBegin(pan))
    }

    func testGestureRecognizerShouldBegin_downwardDrag_scrollViewAtTop_returnsTrue() {
        let vc = UIViewController()
        _ = vc.view
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 400))
        scrollView.contentSize = CGSize(width: 375, height: 800)
        scrollView.contentOffset = .zero

        let transition = BottomSheetInteractiveDismissTransition(
            presentedViewController: vc,
            scrollView: scrollView
        )

        let pan = MockPanGestureRecognizer()
        pan.mockVelocity = CGPoint(x: 0, y: 100) // downward
        XCTAssertTrue(transition.gestureRecognizerShouldBegin(pan))
    }

    func testGestureRecognizerShouldBegin_downwardDrag_scrollViewScrolledDown_returnsFalse() {
        let vc = UIViewController()
        _ = vc.view
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 375, height: 400))
        scrollView.contentSize = CGSize(width: 375, height: 800)
        scrollView.contentOffset = CGPoint(x: 0, y: 100) // scrolled down

        let transition = BottomSheetInteractiveDismissTransition(
            presentedViewController: vc,
            scrollView: scrollView
        )

        let pan = MockPanGestureRecognizer()
        pan.mockVelocity = CGPoint(x: 0, y: 100) // downward
        XCTAssertFalse(transition.gestureRecognizerShouldBegin(pan))
    }

    func testGestureRecognizerShouldBegin_zeroDragVelocity_returnsFalse() {
        let vc = UIViewController()
        _ = vc.view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let pan = MockPanGestureRecognizer()
        pan.mockVelocity = .zero
        XCTAssertFalse(transition.gestureRecognizerShouldBegin(pan))
    }

    func testGestureRecognizerShouldRecognizeSimultaneously_returnsFalse() {
        let vc = UIViewController()
        _ = vc.view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let gesture1 = UIPanGestureRecognizer()
        let gesture2 = UIPanGestureRecognizer()
        let result = transition.gestureRecognizer(gesture1, shouldRecognizeSimultaneouslyWith: gesture2)
        XCTAssertFalse(result)
    }

    func testGestureRecognizerShouldBeRequiredToFail_returnsTrue() {
        let vc = UIViewController()
        _ = vc.view
        let transition = BottomSheetInteractiveDismissTransition(presentedViewController: vc)

        let gesture1 = UIPanGestureRecognizer()
        let gesture2 = UIPanGestureRecognizer()
        let result = transition.gestureRecognizer(gesture1, shouldBeRequiredToFailBy: gesture2)
        XCTAssertTrue(result)
    }
}

private class MockPanGestureRecognizer: UIPanGestureRecognizer {
    var mockVelocity: CGPoint = .zero

    override func velocity(in view: UIView?) -> CGPoint {
        mockVelocity
    }
}
