//
//  RecurringOptionsTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 18/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import AirwallexPayment

final class RecurringOptionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding_customer() {
        let model = RecurringOptions(nextTriggeredBy: .customerType)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "customer")
        XCTAssertEqual(jsonObject.count, 1)
    }

    func testEncoding_merchant() {
        let model = RecurringOptions(nextTriggeredBy: .merchantType)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject.count, 1)
    }
    func testEncoding_merchantUnscheduled() {
        let model = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .unscheduled)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "unscheduled")
        XCTAssertEqual(jsonObject.count, 2)
    }
    
    func testEncoding_merchantScheduled() {
        let model = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "scheduled")
        XCTAssertEqual(jsonObject.count, 2)
    }
    
    func testEncoding_merchantUndefined() {
        let model = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .undefined)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertNil(jsonObject["merchant_trigger_reason"])
        XCTAssertEqual(jsonObject.count, 1)
    }
    
    func testEncoding_merchantInstallments() {
        let model = RecurringOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .installments)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "installments")
        XCTAssertEqual(jsonObject.count, 2)
    }
}
