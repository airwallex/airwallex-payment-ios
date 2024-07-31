//
//  UIViewControllerUtilsTests.swift
//  CoreTests
//
//  Created by Tony He (CTR) on 2024/7/31.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import UIKit
import XCTest

@testable import Core

class UIViewControllerUtilsTests: XCTestCase {
    var viewController: UIViewController!

    override func setUpWithError() throws {
        viewController = UIViewController()
        viewController.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        viewController = nil
    }

    func testEnableTapToEndEditing() {
        // Arrange
        let window = UIWindow()
        window.addSubview(viewController.view)
        viewController.enableTapToEndEditing()

        // Act
        viewController.view.endEditing(false)

        // Assert
        XCTAssert(viewController.view.gestureRecognizers?.count == 1)

        let tapGesture = viewController.view.gestureRecognizers?.first as? UITapGestureRecognizer
        XCTAssertNotNil(tapGesture)
        XCTAssertEqual(tapGesture?.cancelsTouchesInView, false)
    }

    func testStartAnimating() {
        // Act
        viewController.startAnimating()

        // Assert
        guard let activityIndicator = UIViewController.activityIndicator else {
            XCTFail("Activity indicator should be created")
            return
        }

        XCTAssertTrue(activityIndicator.isAnimating)
        XCTAssertTrue(viewController.view.subviews.contains(activityIndicator))
        XCTAssertEqual(activityIndicator.style, .large)
    }

    func testStopAnimating() {
        // Arrange
        viewController.startAnimating()

        // Act
        viewController.stopAnimating()

        // Assert
        guard let activityIndicator = UIViewController.activityIndicator else {
            XCTAssertNil(UIViewController.activityIndicator)
            return
        }

        XCTAssertFalse(activityIndicator.isAnimating)
        XCTAssertFalse(viewController.view.subviews.contains(activityIndicator))
    }

    func testDismissKeyboard() {
        // Arrange
        let textField = UITextField()
        viewController.view.addSubview(textField)
        textField.becomeFirstResponder()

        // Act
        viewController.dismissKeyboard()

        // Assert after
        XCTAssertFalse(textField.isFirstResponder)
    }
}
