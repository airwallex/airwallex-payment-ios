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

    func testEditingEventObserver() {
        var count = 0
        let observer = BeginEditingEventObserver {
            count += 1
        }
        let textField = UITextField()
        observer.handleEditingEvent(event: .editingDidBegin, for: textField)
        observer.handleEditingEvent(event: .editingDidBegin, for: textField)
        XCTAssertEqual(count, 2)
        observer.handleEditingEvent(event: .editingDidEnd, for: textField)
        XCTAssertEqual(count, 2)
        observer.handleEditingEvent(event: .editingChanged, for: textField)
        XCTAssertEqual(count, 2)
    }
    
    func testUserEditingEventObserver() {
        let sender = UITextField()
        var observedEvent = UITextField.Event.allEditingEvents
        let observer = UserEditingEventObserver { event, _ in
            observedEvent = event
        }
        observer.handleEditingEvent(event: .editingDidBegin, for: sender)
        XCTAssertEqual(observedEvent, .editingDidBegin)
        
        observer.handleEditingEvent(event: .editingChanged, for: sender)
        XCTAssertEqual(observedEvent, .editingChanged)
        
        observer.handleEditingEvent(event: .editingDidEnd, for: sender)
        XCTAssertEqual(observedEvent, .editingDidEnd)
    }
}
