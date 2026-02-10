//
//  EventsTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/4/11.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import AirwallexCore
@testable @_spi(AWX) import AirwallexPayment
import UIKit
import XCTest

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
            "value": "mock_value",
            AnalyticEvent.Fields.message.rawValue: error.localizedDescription,
            AnalyticEvent.Fields.eventType.rawValue: error.eventType,
        ]
        XCTAssertEqual(info, expected)
    }

    // MARK: - buildSessionLevelInfo Tests

    func testBuildSessionLevelInfoWithDefaults() {
        let session = AWXOneOffSession()
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        session.paymentIntent = paymentIntent

        let info = AnalyticsLogger.buildSessionLevelInfo(session: session, extraInfo: nil)

        XCTAssertEqual(info["layout"] as? String, "none")
        XCTAssertEqual(info["expressCheckout"] as? Bool, false)
        XCTAssertEqual(info["transactionMode"] as? String, "oneoff")
        XCTAssertEqual(info.count, 3)
    }

    func testBuildSessionLevelInfoWithRecurringSession() {
        let session = AWXRecurringSession()

        let info = AnalyticsLogger.buildSessionLevelInfo(session: session, extraInfo: nil)

        XCTAssertEqual(info["layout"] as? String, "none")
        XCTAssertEqual(info["expressCheckout"] as? Bool, false)
        XCTAssertEqual(info["transactionMode"] as? String, "recurring")
    }

    func testBuildSessionLevelInfoWithRecurringWithIntentSession() {
        let session = AWXRecurringWithIntentSession()
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        session.paymentIntent = paymentIntent

        let info = AnalyticsLogger.buildSessionLevelInfo(session: session, extraInfo: nil)

        XCTAssertEqual(info["transactionMode"] as? String, "recurring")
    }

    func testBuildSessionLevelInfoWithExtraInfo() {
        let session = AWXOneOffSession()
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        session.paymentIntent = paymentIntent

        let extraInfo: [AnalyticEvent.Fields: Any] = [
            .launchType: "dropin",
            .paymentMethod: AWXCardKey
        ]

        let info = AnalyticsLogger.buildSessionLevelInfo(session: session, extraInfo: extraInfo)

        XCTAssertEqual(info["layout"] as? String, "none")
        XCTAssertEqual(info["expressCheckout"] as? Bool, false)
        XCTAssertEqual(info["transactionMode"] as? String, "oneoff")
        XCTAssertEqual(info["launchType"] as? String, "dropin")
        XCTAssertEqual(info["paymentMethod"] as? String, AWXCardKey)
        XCTAssertEqual(info.count, 5)
    }

    func testBuildSessionLevelInfoExtraInfoOverridesDefaults() {
        let session = AWXOneOffSession()
        let paymentIntent = AWXPaymentIntent()
        paymentIntent.id = "test_intent_id"
        session.paymentIntent = paymentIntent

        let extraInfo: [AnalyticEvent.Fields: Any] = [
            .layout: "tab",
            .expressCheckout: true
        ]

        let info = AnalyticsLogger.buildSessionLevelInfo(session: session, extraInfo: extraInfo)

        // extraInfo should override default values
        XCTAssertEqual(info["layout"] as? String, "tab")
        XCTAssertEqual(info["expressCheckout"] as? Bool, true)
        XCTAssertEqual(info["transactionMode"] as? String, "oneoff")
        XCTAssertEqual(info.count, 3)
    }
}
