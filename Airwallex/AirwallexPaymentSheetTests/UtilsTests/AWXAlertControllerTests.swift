//
//  AWXAlertControllerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class AWXAlertControllerTests: XCTestCase {
    func testTintColor() {
        _ = AWXAlertController(nibName: nil, bundle: nil)
        let tintColor = UIView.appearance(whenContainedInInstancesOf: [AWXAlertController.self]).tintColor
        XCTAssertEqual(tintColor?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
                       UIColor.awxColor(.theme).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
                       "The tintColor should be set to the theme color.")
        XCTAssertEqual(tintColor?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
                       UIColor.awxColor(.theme).resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)),
                       "The tintColor should be set to the theme color.")
    }
    
    // test allert is shown as expected
    func testShowAlert() {
        let mockDelegate = MockPaymentResultDelegate()
        
        mockDelegate.showAlert(title: "Test Title", message: "Test Message")
        XCTAssertNotNil(mockDelegate.presentedViewControllerSpy)
        XCTAssertTrue(mockDelegate.presentedViewControllerSpy is UIAlertController)
        let alertController = mockDelegate.presentedViewControllerSpy as? UIAlertController
        XCTAssertEqual(alertController?.title, "Test Title")
        XCTAssertEqual(alertController?.message, "Test Message")
    }
}
