//
//  AWXAlertControllerTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/3/26.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import Payment

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
}
