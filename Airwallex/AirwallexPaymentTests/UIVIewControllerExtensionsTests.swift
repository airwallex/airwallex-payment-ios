//
//  UIVIewControllerExtensionsTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

@testable import AirwallexPayment
import UIKit
import XCTest

class UIVIewControllerExtensionsTests: XCTestCase {

    var viewController: UIViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewController = UIViewController()
        UIApplication.shared.windows.first?.rootViewController = viewController
    }

    override func tearDownWithError() throws {
        viewController = nil
        try super.tearDownWithError()
    }

    func testStartLoading() {
        viewController.startLoading()
        XCTAssertTrue(viewController.isLoading)
        XCTAssertFalse(viewController.view.isUserInteractionEnabled)
    }

    func testStopLoading() {
        viewController.startLoading()
        viewController.stopLoading()
        XCTAssertFalse(viewController.isLoading)
        XCTAssertTrue(viewController.view.isUserInteractionEnabled)
    }

    // MARK: - UIView Loading Extension Tests

    func testViewStartLoading_addsLoadingSpinnerView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.startLoading()

        XCTAssertTrue(view.isLoading)
        XCTAssertFalse(view.isUserInteractionEnabled)
        // Verify loading spinner is added
        let spinnerView = view.subviews.first { $0.accessibilityIdentifier == "loadingSpinnerView" }
        XCTAssertNotNil(spinnerView, "Loading spinner should be added to the view")
    }

    func testViewStartLoading_calledMultipleTimes_reusesExistingIndicator() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.startLoading()
        let spinnerCountAfterFirstCall = view.subviews.filter { $0.accessibilityIdentifier == "loadingSpinnerView" }.count

        view.startLoading()
        let spinnerCountAfterSecondCall = view.subviews.filter { $0.accessibilityIdentifier == "loadingSpinnerView" }.count

        XCTAssertEqual(spinnerCountAfterFirstCall, 1)
        XCTAssertEqual(spinnerCountAfterSecondCall, 1, "Should reuse existing indicator, not add new one")
        XCTAssertTrue(view.isLoading)
    }

    func testViewStopLoading_stopsAnimation() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.startLoading()
        XCTAssertTrue(view.isLoading)

        view.stopLoading()

        XCTAssertFalse(view.isLoading)
        XCTAssertTrue(view.isUserInteractionEnabled)
    }

    func testViewStopLoading_whenNotLoading_doesNotCrash() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // Should not crash when calling stop without start
        view.stopLoading()
        XCTAssertFalse(view.isLoading)
        XCTAssertTrue(view.isUserInteractionEnabled)
    }

    func testViewIsLoading_returnsFalseWhenNoIndicator() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertFalse(view.isLoading)
    }

    func testViewIsLoading_returnsTrueWhenAnimating() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.startLoading()
        XCTAssertTrue(view.isLoading)
    }

    func testViewIsLoading_returnsFalseAfterStopping() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.startLoading()
        view.stopLoading()
        XCTAssertFalse(view.isLoading)
    }

    // MARK: - UIViewController.topMost Tests

    func testTopMost_fromNilRootVC_returnsNil() {
        let topVC = UIViewController.topMost(from: nil)
        XCTAssertNil(topVC)
    }

    func testTopMost_fromRegularVC_returnsSameVC() {
        let regularVC = UIViewController()
        let topVC = UIViewController.topMost(from: regularVC)
        XCTAssertEqual(topVC, regularVC)
    }

    func testTopMost_fromNavigationController_returnsVisibleVC() {
        let rootVC = UIViewController()
        let pushedVC = UIViewController()
        let navController = UINavigationController(rootViewController: rootVC)
        navController.pushViewController(pushedVC, animated: false)

        let topVC = UIViewController.topMost(from: navController)

        XCTAssertEqual(topVC, pushedVC)
    }

    func testTopMost_fromTabBarController_returnsSelectedVC() {
        let firstVC = UIViewController()
        let secondVC = UIViewController()
        let tabController = UITabBarController()
        tabController.viewControllers = [firstVC, secondVC]
        tabController.selectedIndex = 1

        let topVC = UIViewController.topMost(from: tabController)

        XCTAssertEqual(topVC, secondVC)
    }

    func testTopMost_fromNavigationInsideTabBar_returnsTopOfNavigation() {
        let rootVC = UIViewController()
        let pushedVC = UIViewController()
        let navController = UINavigationController(rootViewController: rootVC)
        navController.pushViewController(pushedVC, animated: false)

        let otherVC = UIViewController()
        let tabController = UITabBarController()
        tabController.viewControllers = [navController, otherVC]
        tabController.selectedIndex = 0

        let topVC = UIViewController.topMost(from: tabController)

        XCTAssertEqual(topVC, pushedVC)
    }

    func testTopMost_fromEmptyNavigationController_returnsNil() {
        let navController = UINavigationController()

        let topVC = UIViewController.topMost(from: navController)

        XCTAssertNil(topVC)
    }

    func testTopMost_fromTabBarWithNoSelectedVC_returnsNil() {
        let tabController = UITabBarController()
        tabController.viewControllers = []

        let topVC = UIViewController.topMost(from: tabController)

        XCTAssertNil(topVC)
    }
}
