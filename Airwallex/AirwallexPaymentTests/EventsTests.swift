//
//  EventsTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import UIKit
import XCTest
@testable @_spi(AWX) import AirwallexPayment
import AirwallexCore

class EventsTests: XCTestCase {
   
    func testProcessEventInfo() {
        let event = AnalyticEvent.PaymentMethodView.applePay
        let field = AnalyticEvent.Fields.subtype
        let additionalInfo = [field: field.rawValue]
        let (processedName, processedInfo) = AnalyticsLogger.processEventInfo(event: event, extraInfo: additionalInfo)
        XCTAssertEqual(processedName, event.rawValue)
        XCTAssertEqual(processedInfo.count, 1)
        let value = processedInfo[field.rawValue] as? String
        XCTAssertNotNil(value)
        XCTAssertEqual(value, field.rawValue)
    }
    
    
    enum MockError: ErrorLoggable {
        case foo
        
        var eventName: String {
            return "mock_error_name"
        }
        
        var eventType: String? {
            return "mock_error_type"
        }
        
        var errorDescription: String? {
            return "mock_error_description"
        }
    }
    
    func testProcessErrorInfo() {
        let error = MockError.foo
        let (processedName, processedInfo) = AnalyticsLogger.processErrorInfo(
            error: error,
            extraInfo: [AnalyticEvent.Fields.value: "mock_value"]
        )
        XCTAssertEqual(processedName, error.eventName)
        guard let info = processedInfo as? [String: String] else {
            XCTFail()
            return
        }
        
        let expected = [
            "value":"mock_value",
            AnalyticEvent.Fields.message.rawValue : error.localizedDescription,
            AnalyticEvent.Fields.eventType.rawValue: error.eventType,
        ]
        XCTAssertEqual(info, expected)
    }
}
