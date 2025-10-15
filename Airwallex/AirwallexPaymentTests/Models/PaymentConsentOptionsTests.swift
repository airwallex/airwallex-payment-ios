//
//  PaymentConsentOptionsTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 18/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import AirwallexPayment
@testable import AirwallexCore

final class PaymentConsentOptionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding_customer() {
        let model = PaymentConsentOptions(nextTriggeredBy: .customerType)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "customer")
        XCTAssertEqual(jsonObject.count, 1)
    }

    func testEncoding_merchant() {
        let model = PaymentConsentOptions(nextTriggeredBy: .merchantType)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject.count, 1)
    }
    func testEncoding_merchantUnscheduled() {
        let model = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .unscheduled)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "unscheduled")
        XCTAssertEqual(jsonObject.count, 2)
    }
    
    func testEncoding_merchantScheduled() {
        let model = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .scheduled)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "scheduled")
        XCTAssertEqual(jsonObject.count, 2)
    }
    
    func testEncoding_merchantUndefined() {
        let model = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .undefined)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertNil(jsonObject["merchant_trigger_reason"])
        XCTAssertEqual(jsonObject.count, 1)
    }
    
    func testEncoding_merchantInstallments() {
        let model = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: .installments)
        let jsonObject = model.encodeToJSON()
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "installments")
        XCTAssertEqual(jsonObject.count, 2)
    }
    
    func testEncoding_withTermsOfUse() {
        let paymentSchedule = PaymentSchedule(period: 3, periodUnit: .month)
        let termsOfUse = TermsOfUse(
            billingCycleChargeDay: 15,
            fixedPaymentAmount: NSDecimalNumber(value: 100.00),
            paymentAmountType: .fixed,
            paymentCurrency: "USD",
            paymentSchedule: paymentSchedule,
            totalBillingCycles: 12
        )
        
        let model = PaymentConsentOptions(
            nextTriggeredBy: .merchantType,
            merchantTriggerReason: .scheduled,
            termsOfUse: termsOfUse
        )
        
        let jsonObject = model.encodeToJSON()
        
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "scheduled")
        XCTAssertNotNil(jsonObject["terms_of_use"])
        
        let termsOfUseJSON = jsonObject["terms_of_use"] as! [String: Any]
        XCTAssertEqual(termsOfUseJSON["billing_cycle_charge_day"] as? Int, 15)
        XCTAssertEqual(termsOfUseJSON["fixed_payment_amount"] as? Double, 100.00)
        XCTAssertEqual(termsOfUseJSON["payment_amount_type"] as? String, "FIXED")
        XCTAssertEqual(termsOfUseJSON["payment_currency"] as? String, "USD")
        XCTAssertEqual(termsOfUseJSON["total_billing_cycles"] as? Int, 12)
        
        let paymentScheduleJSON = termsOfUseJSON["payment_schedule"] as! [String: Any]
        XCTAssertEqual(paymentScheduleJSON["period"] as? Int, 3)
        XCTAssertEqual(paymentScheduleJSON["period_unit"] as? String, "MONTH")
        
        XCTAssertEqual(jsonObject.count, 3) // next_triggered_by, merchant_trigger_reason, terms_of_use
    }
    
    func testEncoding_withoutTermsOfUse() {
        let model = PaymentConsentOptions(
            nextTriggeredBy: .merchantType,
            merchantTriggerReason: .scheduled,
            termsOfUse: nil
        )
        
        let jsonObject = model.encodeToJSON()
        
        XCTAssertEqual(jsonObject["next_triggered_by"] as? String, "merchant")
        XCTAssertEqual(jsonObject["merchant_trigger_reason"] as? String, "scheduled")
        XCTAssertNil(jsonObject["terms_of_use"])
        XCTAssertEqual(jsonObject.count, 2) // next_triggered_by, merchant_trigger_reason
    }
    
    func testValidate() {

        let arr: [AirwallexMerchantTriggerReason] = [.scheduled, .installments, .unscheduled]
        for reason in arr {
            let model = PaymentConsentOptions(nextTriggeredBy: .customerType, merchantTriggerReason: reason)
            XCTAssertNoThrow(try model.validate())
            XCTAssertEqual(model.merchantTriggerReason, .undefined)
        }
        for reason in arr {
            let model = PaymentConsentOptions(nextTriggeredBy: .merchantType, merchantTriggerReason: reason)
            XCTAssertNoThrow(try model.validate())
            XCTAssertEqual(model.merchantTriggerReason, reason)
        }
    }

    // MARK: - Initializer Logic Tests

    func testInit_customerType_automaticallyForcesUndefinedMerchantTriggerReason() {
        // Test that merchantTriggerReason is automatically set to .undefined when nextTriggeredBy is .customerType
        let reasons: [AirwallexMerchantTriggerReason] = [.scheduled, .unscheduled, .installments, .undefined]

        for reason in reasons {
            let model = PaymentConsentOptions(
                nextTriggeredBy: .customerType,
                merchantTriggerReason: reason
            )

            XCTAssertEqual(model.nextTriggeredBy, .customerType)
            XCTAssertEqual(model.merchantTriggerReason, .undefined,
                          "merchantTriggerReason should be forced to .undefined when nextTriggeredBy is .customerType, regardless of input value")
        }
    }

    func testInit_merchantType_preservesMerchantTriggerReason() {
        // Test that merchantTriggerReason is preserved when nextTriggeredBy is .merchantType
        let testCases: [AirwallexMerchantTriggerReason] = [.scheduled, .unscheduled, .installments, .undefined]

        for reason in testCases {
            let model = PaymentConsentOptions(
                nextTriggeredBy: .merchantType,
                merchantTriggerReason: reason
            )

            XCTAssertEqual(model.nextTriggeredBy, .merchantType)
            XCTAssertEqual(model.merchantTriggerReason, reason,
                          "merchantTriggerReason should be preserved when nextTriggeredBy is .merchantType")
        }
    }
}
