//
//  EditingEventObserverTests.swift
//  PaymentTests
//
//  Created by Weiping Li on 2025/4/1.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPayment
@testable import AirwallexPaymentSheet

class EditingEventObserverTests: XCTestCase {

    func testBeginEditingEventObserver() {
        var count = 0
        let observer = BeginEditingEventObserver {
            count += 1
        }
        let textField = UITextField()
        observer.textFieldDidBeginEditing(textField)
        observer.textFieldDidBeginEditing(textField)
        XCTAssertEqual(count, 2)
    }
    
}
