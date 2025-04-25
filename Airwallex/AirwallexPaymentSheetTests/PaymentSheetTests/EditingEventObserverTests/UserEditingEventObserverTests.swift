//
//  UserEditingEventObserverTests.swift
//  AirwallexPaymentSheetTests
//
//  Created by Weiping Li on 2025/4/21.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable import AirwallexPaymentSheet

class UserEditingEventObserverTests: XCTestCase {
    
    func testEditingEvents() {
        let events: [UIControl.Event] = [.editingDidBegin, .editingChanged, .editingDidEnd]
        var observedEvents = [UIControl.Event]()
        let textField = UITextField()
        let observer = UserEditingEventObserver { event, field in
            observedEvents.append(event)
            XCTAssert(textField === field)
        }
        for event in events {
            observer.handleEditingEvent(event: event, for: textField)
        }
        XCTAssertEqual(events, observedEvents)
    }
}
