//
//  TermsOfUseTests.swift
//  AirwallexPaymentTests
//
//  Created by Weiping Li on 2025/9/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import XCTest
@testable import AirwallexPayment
import Foundation

final class TermsOfUseTests: XCTestCase {
    
    private var sampleStartDate: Date!
    private var sampleEndDate: Date!
    private var paymentSchedule: PaymentSchedule!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create sample dates
        let calendar = Calendar.current
        sampleStartDate = calendar.date(from: DateComponents(year: 2025, month: 9, day: 1))
        sampleEndDate = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1))
        
        // Create sample payment schedule
        paymentSchedule = PaymentSchedule(period: 1, periodUnit: .month)
    }
    
    // MARK: - Initialization Tests
    
    func testInit_withDefaultParameters() {
        let termsOfUse = TermsOfUse(paymentAmountType: .fixed)
        
        XCTAssertEqual(termsOfUse.billingCycleChargeDay, 0)
        XCTAssertNil(termsOfUse.endDate)
        XCTAssertNil(termsOfUse.firstPaymentAmount)
        XCTAssertNil(termsOfUse.fixedPaymentAmount)
        XCTAssertNil(termsOfUse.maxPaymentAmount)
        XCTAssertNil(termsOfUse.minPaymentAmount)
        XCTAssertEqual(termsOfUse.paymentAmountType, .fixed)
        XCTAssertNil(termsOfUse.paymentCurrency)
        XCTAssertNil(termsOfUse.paymentSchedule)
        XCTAssertNil(termsOfUse.startDate)
        XCTAssertEqual(termsOfUse.totalBillingCycles, 0)
    }
    
    func testInit_withAllParameters() {
        let firstPaymentAmount = NSDecimalNumber(value: 100.50)
        let fixedPaymentAmount = NSDecimalNumber(value: 50.00)
        let maxPaymentAmount = NSDecimalNumber(value: 200.00)
        let minPaymentAmount = NSDecimalNumber(value: 10.00)
        
        let termsOfUse = TermsOfUse(
            billingCycleChargeDay: 15,
            endDate: sampleEndDate,
            firstPaymentAmount: firstPaymentAmount,
            fixedPaymentAmount: fixedPaymentAmount,
            maxPaymentAmount: maxPaymentAmount,
            minPaymentAmount: minPaymentAmount,
            paymentAmountType: .variable,
            paymentCurrency: "USD",
            paymentSchedule: paymentSchedule,
            startDate: sampleStartDate,
            totalBillingCycles: 12
        )
        
        XCTAssertEqual(termsOfUse.billingCycleChargeDay, 15)
        XCTAssertEqual(termsOfUse.endDate, sampleEndDate)
        XCTAssertEqual(termsOfUse.firstPaymentAmount, firstPaymentAmount)
        XCTAssertEqual(termsOfUse.fixedPaymentAmount, fixedPaymentAmount)
        XCTAssertEqual(termsOfUse.maxPaymentAmount, maxPaymentAmount)
        XCTAssertEqual(termsOfUse.minPaymentAmount, minPaymentAmount)
        XCTAssertEqual(termsOfUse.paymentAmountType, .variable)
        XCTAssertEqual(termsOfUse.paymentCurrency, "USD")
        XCTAssertEqual(termsOfUse.paymentSchedule, paymentSchedule)
        XCTAssertEqual(termsOfUse.startDate, sampleStartDate)
        XCTAssertEqual(termsOfUse.totalBillingCycles, 12)
    }
    
    // MARK: - PaymentAmountType Enum Tests
    
    func testPaymentAmountType_allCases() {
        XCTAssertEqual(PaymentAmountType.allCases.count, 2)
        XCTAssertTrue(PaymentAmountType.allCases.contains(.fixed))
        XCTAssertTrue(PaymentAmountType.allCases.contains(.variable))
    }
    
    // MARK: - PeriodUnit Enum Tests
    
    func testPeriodUnit_allCases() {
        XCTAssertEqual(PeriodUnit.allCases.count, 4)
        XCTAssertTrue(PeriodUnit.allCases.contains(.day))
        XCTAssertTrue(PeriodUnit.allCases.contains(.week))
        XCTAssertTrue(PeriodUnit.allCases.contains(.month))
        XCTAssertTrue(PeriodUnit.allCases.contains(.year))
    }
    
    // MARK: - PaymentSchedule Tests
    
    func testPaymentSchedule_init() {
        let schedule = PaymentSchedule(period: 2, periodUnit: .week)
        
        XCTAssertEqual(schedule.period, 2)
        XCTAssertEqual(schedule.periodUnit, .week)
    }
    
    func testPaymentSchedule_initWithDefaultPeriod() {
        let schedule = PaymentSchedule(periodUnit: .month)
        
        XCTAssertEqual(schedule.period, 1)
        XCTAssertEqual(schedule.periodUnit, .month)
    }
    
    
    // MARK: - Encoding Tests
    
    func testTermsOfUse_encodeToJSON_basic() {
        let termsOfUse = TermsOfUse(paymentAmountType: .fixed)
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["payment_amount_type"] as? String, "FIXED")
        XCTAssertTrue(json.keys.count >= 1, "JSON should contain at least the payment_amount_type")
    }
    
    func testTermsOfUse_encodeToJSON_fixedAmountType() {
        let fixedAmount = NSDecimalNumber(value: 99.99)
        let termsOfUse = TermsOfUse(
            fixedPaymentAmount: fixedAmount,
            paymentAmountType: .fixed
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["payment_amount_type"] as? String, "FIXED")
        XCTAssertEqual(json["fixed_payment_amount"] as? Double, 99.99)
    }
    
    func testTermsOfUse_encodeToJSON_variableAmountType() {
        let minAmount = NSDecimalNumber(value: 10.00)
        let maxAmount = NSDecimalNumber(value: 500.00)
        let termsOfUse = TermsOfUse(
            maxPaymentAmount: maxAmount,
            minPaymentAmount: minAmount,
            paymentAmountType: .variable
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["payment_amount_type"] as? String, "VARIABLE")
        XCTAssertEqual(json["min_payment_amount"] as? Double, 10.00)
        XCTAssertEqual(json["max_payment_amount"] as? Double, 500.00)
    }
    
    func testTermsOfUse_encodeToJSON_withPaymentSchedule() {
        let schedule = PaymentSchedule(period: 3, periodUnit: .month)
        let termsOfUse = TermsOfUse(
            paymentAmountType: .fixed,
            paymentSchedule: schedule
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertNotNil(json["payment_schedule"])
        let scheduleJSON = json["payment_schedule"] as! [String: Any]
        XCTAssertEqual(scheduleJSON["period"] as? Int, 3)
        XCTAssertEqual(scheduleJSON["period_unit"] as? String, "MONTH")
    }
    
    func testTermsOfUse_encodeToJSON_billingCycleAndTotalCycles() {
        let termsOfUse = TermsOfUse(
            billingCycleChargeDay: 5,
            paymentAmountType: .fixed,
            totalBillingCycles: 24
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["billing_cycle_charge_day"] as? Int, 5)
        XCTAssertEqual(json["total_billing_cycles"] as? Int, 24)
    }
    
    func testTermsOfUse_encodeToJSON_zeroBillingCycleAndTotalCycles() {
        let termsOfUse = TermsOfUse(
            billingCycleChargeDay: 0,
            paymentAmountType: .fixed,
            totalBillingCycles: 0
        )
        
        let json = termsOfUse.encodeToJSON()
        
        // Zero values should not be included in the encoded JSON
        XCTAssertNil(json["billing_cycle_charge_day"])
        XCTAssertNil(json["total_billing_cycles"])
    }
    
    func testTermsOfUse_encodeToJSON_currencyAndDates() {
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 15))!
        
        let termsOfUse = TermsOfUse(
            endDate: endDate,
            paymentAmountType: .variable,
            paymentCurrency: "GBP",
            startDate: startDate
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["payment_currency"] as? String, "GBP")
        XCTAssertEqual(json["start_date"] as? String, "2025-01-15")
        XCTAssertEqual(json["end_date"] as? String, "2025-12-15")
    }
    
    func testTermsOfUse_encodeToJSON_allDecimalFields() {
        let firstPayment = NSDecimalNumber(string: "150.75")
        let fixedPayment = NSDecimalNumber(string: "100.00")
        let maxPayment = NSDecimalNumber(string: "999.99")
        let minPayment = NSDecimalNumber(string: "1.00")
        
        let termsOfUse = TermsOfUse(
            firstPaymentAmount: firstPayment,
            fixedPaymentAmount: fixedPayment,
            maxPaymentAmount: maxPayment,
            minPaymentAmount: minPayment,
            paymentAmountType: .fixed
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["first_payment_amount"] as? Double, 150.75)
        XCTAssertEqual(json["fixed_payment_amount"] as? Double, 100.00)
        XCTAssertEqual(json["max_payment_amount"] as? Double, 999.99)
        XCTAssertEqual(json["min_payment_amount"] as? Double, 1.00)
    }
    
    func testTermsOfUse_encodeToJSON_edgeCaseDecimalValues() {
        let verySmallAmount = NSDecimalNumber(string: "0.01")
        let veryLargeAmount = NSDecimalNumber(string: "99999999.99")
        let zeroAmount = NSDecimalNumber.zero
        
        let termsOfUse = TermsOfUse(
            firstPaymentAmount: verySmallAmount,
            fixedPaymentAmount: veryLargeAmount,
            minPaymentAmount: zeroAmount,
            paymentAmountType: .fixed
        )
        
        let json = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(json["first_payment_amount"] as? Double, 0.01)
        XCTAssertEqual(json["fixed_payment_amount"] as? Double, 99999999.99)
        XCTAssertEqual(json["min_payment_amount"] as? Double, 0.0)
    }
    
    func testTermsOfUse_encodeToJSON_withNilValues() {
        let termsOfUse = TermsOfUse(paymentAmountType: .variable)
        let json = termsOfUse.encodeToJSON()
        
        // Should not include zero values
        XCTAssertNil(json["billing_cycle_charge_day"])
        XCTAssertNil(json["total_billing_cycles"])
        
        // Should not include nil values
        XCTAssertNil(json["end_date"])
        XCTAssertNil(json["first_payment_amount"])
        XCTAssertNil(json["fixed_payment_amount"])
        XCTAssertNil(json["max_payment_amount"])
        XCTAssertNil(json["min_payment_amount"])
        XCTAssertNil(json["payment_currency"])
        XCTAssertNil(json["payment_schedule"])
        XCTAssertNil(json["start_date"])
        
        // Should include required field
        XCTAssertEqual(json["payment_amount_type"] as? String, "VARIABLE")
    }
    
    func testTermsOfUse_encoding() throws {
        let firstPaymentAmount = NSDecimalNumber(value: 100.50)
        let fixedPaymentAmount = NSDecimalNumber(value: 50.00)
        
        let termsOfUse = TermsOfUse(
            billingCycleChargeDay: 15,
            endDate: sampleEndDate,
            firstPaymentAmount: firstPaymentAmount,
            fixedPaymentAmount: fixedPaymentAmount,
            paymentAmountType: .fixed,
            paymentCurrency: "USD",
            paymentSchedule: paymentSchedule,
            startDate: sampleStartDate,
            totalBillingCycles: 12
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(termsOfUse)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["billing_cycle_charge_day"] as? Int, 15)
        XCTAssertEqual(json["end_date"] as? String, "2026-09-01")
        XCTAssertEqual(json["first_payment_amount"] as? Double, 100.50)
        XCTAssertEqual(json["fixed_payment_amount"] as? Double, 50.00)
        XCTAssertEqual(json["payment_amount_type"] as? String, "FIXED")
        XCTAssertEqual(json["payment_currency"] as? String, "USD")
        XCTAssertEqual(json["start_date"] as? String, "2025-09-01")
        XCTAssertEqual(json["total_billing_cycles"] as? Int, 12)
        
        // Verify payment schedule is included
        XCTAssertNotNil(json["payment_schedule"])
    }
    
    func testTermsOfUse_encodingWithNilValues() throws {
        let termsOfUse = TermsOfUse(paymentAmountType: .variable)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(termsOfUse)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        // Should not include zero values
        XCTAssertNil(json["billing_cycle_charge_day"])
        XCTAssertNil(json["total_billing_cycles"])
        
        // Should not include nil values
        XCTAssertNil(json["end_date"])
        XCTAssertNil(json["first_payment_amount"])
        XCTAssertNil(json["fixed_payment_amount"])
        XCTAssertNil(json["max_payment_amount"])
        XCTAssertNil(json["min_payment_amount"])
        XCTAssertNil(json["payment_currency"])
        XCTAssertNil(json["payment_schedule"])
        XCTAssertNil(json["start_date"])
        
        // Should include required field
        XCTAssertEqual(json["payment_amount_type"] as? String, "VARIABLE")
    }
    
    func testPaymentSchedule_encoding() throws {
        let schedule = PaymentSchedule(period: 2, periodUnit: .week)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(schedule)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["period"] as? Int, 2)
        XCTAssertEqual(json["period_unit"] as? String, "WEEK")
    }
    
    func testPaymentSchedule_encodingWithZeroPeriod() throws {
        let schedule = PaymentSchedule(period: 0, periodUnit: .day)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(schedule)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        // Should not include zero period but should include period_unit
        XCTAssertNil(json["period"])
        XCTAssertEqual(json["period_unit"] as? String, "DAY")
    }
    
    // MARK: - AWXJSONEncodable Tests
    
    func testTermsOfUse_AWXJSONEncodable() {
        let termsOfUse = TermsOfUse(
            billingCycleChargeDay: 10,
            paymentAmountType: .fixed,
            paymentCurrency: "EUR",
            totalBillingCycles: 6
        )
        
        let jsonDict = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(jsonDict["billing_cycle_charge_day"] as? Int, 10)
        XCTAssertEqual(jsonDict["payment_amount_type"] as? String, "FIXED")
        XCTAssertEqual(jsonDict["payment_currency"] as? String, "EUR")
        XCTAssertEqual(jsonDict["total_billing_cycles"] as? Int, 6)
    }
    
    // MARK: - Helper Function Tests
    
    func testFormatPaymentAmountType() {
        let fixedTerms = TermsOfUse(paymentAmountType: .fixed)
        let variableTerms = TermsOfUse(paymentAmountType: .variable)
        
        let fixedJSON = fixedTerms.encodeToJSON()
        let variableJSON = variableTerms.encodeToJSON()
        
        XCTAssertEqual(fixedJSON["payment_amount_type"] as? String, "FIXED")
        XCTAssertEqual(variableJSON["payment_amount_type"] as? String, "VARIABLE")
    }
    
    func testFormatPeriodUnit() {
        let daySchedule = PaymentSchedule(period: 1, periodUnit: .day)
        let weekSchedule = PaymentSchedule(period: 1, periodUnit: .week)
        let monthSchedule = PaymentSchedule(period: 1, periodUnit: .month)
        let yearSchedule = PaymentSchedule(period: 1, periodUnit: .year)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let dayData = try! encoder.encode(daySchedule)
        let weekData = try! encoder.encode(weekSchedule)
        let monthData = try! encoder.encode(monthSchedule)
        let yearData = try! encoder.encode(yearSchedule)
        
        let dayJSON = try! JSONSerialization.jsonObject(with: dayData) as! [String: Any]
        let weekJSON = try! JSONSerialization.jsonObject(with: weekData) as! [String: Any]
        let monthJSON = try! JSONSerialization.jsonObject(with: monthData) as! [String: Any]
        let yearJSON = try! JSONSerialization.jsonObject(with: yearData) as! [String: Any]
        
        XCTAssertEqual(dayJSON["period_unit"] as? String, "DAY")
        XCTAssertEqual(weekJSON["period_unit"] as? String, "WEEK")
        XCTAssertEqual(monthJSON["period_unit"] as? String, "MONTH")
        XCTAssertEqual(yearJSON["period_unit"] as? String, "YEAR")
    }
    
    func testFormatDate() {
        let calendar = Calendar.current
        let testDate = calendar.date(from: DateComponents(year: 2025, month: 12, day: 25))!
        
        let termsOfUse = TermsOfUse(
            endDate: testDate,
            paymentAmountType: .fixed,
            startDate: testDate
        )
        
        let jsonDict = termsOfUse.encodeToJSON()
        
        XCTAssertEqual(jsonDict["start_date"] as? String, "2025-12-25")
        XCTAssertEqual(jsonDict["end_date"] as? String, "2025-12-25")
    }
    
    func testFormatDate_withNilDate() {
        let termsOfUse = TermsOfUse(paymentAmountType: .fixed)
        let jsonDict = termsOfUse.encodeToJSON()
        
        XCTAssertNil(jsonDict["start_date"])
        XCTAssertNil(jsonDict["end_date"])
    }
    
    // MARK: - Edge Cases
    
    func testNSDecimalNumber_encoding() throws {
        let smallAmount = NSDecimalNumber(string: "0.01")
        let largeAmount = NSDecimalNumber(string: "999999.99")
        
        let termsOfUse = TermsOfUse(
            firstPaymentAmount: smallAmount,
            fixedPaymentAmount: largeAmount,
            paymentAmountType: .fixed
        )
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(termsOfUse)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["first_payment_amount"] as? Double, 0.01)
        XCTAssertEqual(json["fixed_payment_amount"] as? Double, 999999.99)
    }
}