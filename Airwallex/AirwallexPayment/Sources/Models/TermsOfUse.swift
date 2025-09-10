//
//  TermsOfUse.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/9/9.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

/// Terms to specify how this Payment Consent will be used
@objc
public final class TermsOfUse: NSObject {
    /// The granularity per billing cycle. Required when payment_schedule.period_unit is WEEK, MONTH, or YEAR.
    @objc public let billingCycleChargeDay: Int
    
    /// End date to expect payment request.
    /// This Date object will be converted to a string of the format yyyy-MM-dd during JSON encoding.
    @objc public let endDate: Date?
    
    /// The first payment. It could include the costs associated with the first debited amount.
    /// Optional if payment agreement type is VARIABLE.
    @objc public let firstPaymentAmount: NSDecimalNumber?
    
    /// The fixed payment amount that can be charged for a single payment.
    /// Required if payment agreement type is FIXED.
    @objc public let fixedPaymentAmount: NSDecimalNumber?
    
    /// The maximum payment amount that can be charged for a single payment.
    /// Optional if payment agreement type is VARIABLE.
    @objc public let maxPaymentAmount: NSDecimalNumber?
    
    /// The minimum payment amount that can be charged for a single payment.
    /// Optional if payment agreement type is VARIABLE.
    @objc public let minPaymentAmount: NSDecimalNumber?
    
    /// The agreed type of amounts for subsequent payment. Should be one of FIXED, VARIABLE.
    @objc public let paymentAmountType: PaymentAmountType
    
    /// The currency of this payment
    @objc public let paymentCurrency: String?
    
    /// Payment schedule configuration
    /// Required if merchant_trigger_reason = scheduled
    @objc public let paymentSchedule: PaymentSchedule?
    
    /// Start date to expect payment request.
    /// This Date object will be converted to a string of the format yyyy-MM-dd during JSON encoding.
    @objc public let startDate: Date?
    
    /// The total number of billing cycles.
    /// The mandate will continue indefinitely if totalBillingCycles is null.
    @objc public let totalBillingCycles: Int
    
    @objc public init(billingCycleChargeDay: Int = 0,
                      endDate: Date? = nil,
                      firstPaymentAmount: NSDecimalNumber? = nil,
                      fixedPaymentAmount: NSDecimalNumber? = nil,
                      maxPaymentAmount: NSDecimalNumber? = nil,
                      minPaymentAmount: NSDecimalNumber? = nil,
                      paymentAmountType: PaymentAmountType,
                      paymentCurrency: String? = nil,
                      paymentSchedule: PaymentSchedule? = nil,
                      startDate: Date? = nil,
                      totalBillingCycles: Int = 0) {
        self.billingCycleChargeDay = billingCycleChargeDay
        self.endDate = endDate
        self.firstPaymentAmount = firstPaymentAmount
        self.fixedPaymentAmount = fixedPaymentAmount
        self.maxPaymentAmount = maxPaymentAmount
        self.minPaymentAmount = minPaymentAmount
        self.paymentAmountType = paymentAmountType
        self.paymentCurrency = paymentCurrency
        self.paymentSchedule = paymentSchedule
        self.startDate = startDate
        self.totalBillingCycles = totalBillingCycles
    }
}

/// Payment schedule configuration
@objc
public final class PaymentSchedule: NSObject {
    /// The number of period units between billing cycles.
    /// Required when merchant_trigger_reason = scheduled
    @objc public let period: Int
    
    /// Specifies billing frequency. One of DAY, WEEK, MONTH, and YEAR.
    /// Required when merchant_trigger_reason = scheduled
    @objc public let periodUnit: PeriodUnit
    
    @objc public init(period: Int = 1,
                      periodUnit: PeriodUnit) {
        self.period = period
        self.periodUnit = periodUnit
    }
}

// MARK: - Enums

/// Payment amount type enumeration
@objc
public enum PaymentAmountType: Int, CaseIterable {
    case fixed
    case variable
}

/// Period unit enumeration for billing frequency
@objc
public enum PeriodUnit: Int, CaseIterable {
    case day
    case week
    case month
    case year
}

// MARK: - Encodable Extensions

extension TermsOfUse: Encodable {
    enum CodingKeys: String, CodingKey {
        case billingCycleChargeDay
        case endDate
        case firstPaymentAmount
        case fixedPaymentAmount
        case maxPaymentAmount
        case minPaymentAmount
        case paymentAmountType
        case paymentCurrency
        case paymentSchedule
        case startDate
        case totalBillingCycles
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if billingCycleChargeDay != 0 {
            try container.encode(billingCycleChargeDay, forKey: .billingCycleChargeDay)
        }
        try container.encodeIfPresent(formatDate(endDate), forKey: .endDate)
        try container.encodeIfPresent(firstPaymentAmount?.decimalValue, forKey: .firstPaymentAmount)
        try container.encodeIfPresent(fixedPaymentAmount?.decimalValue, forKey: .fixedPaymentAmount)
        try container.encodeIfPresent(maxPaymentAmount?.decimalValue, forKey: .maxPaymentAmount)
        try container.encodeIfPresent(minPaymentAmount?.decimalValue, forKey: .minPaymentAmount)
        try container.encode(formatPaymentAmountType(paymentAmountType), forKey: .paymentAmountType)
        try container.encodeIfPresent(paymentCurrency, forKey: .paymentCurrency)
        try container.encodeIfPresent(paymentSchedule, forKey: .paymentSchedule)
        try container.encodeIfPresent(formatDate(startDate), forKey: .startDate)
        if totalBillingCycles != 0 {
            try container.encode(totalBillingCycles, forKey: .totalBillingCycles)
        }
    }
}

extension PaymentSchedule: Encodable {
    enum CodingKeys: String, CodingKey {
        case period
        case periodUnit
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if period > 0 {
            try container.encode(period, forKey: .period)
        }
        try container.encode(formatPeriodUnit(periodUnit), forKey: .periodUnit)
    }
}

extension TermsOfUse: AWXJSONEncodable {
    public func encodeToJSON() -> [AnyHashable : Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let data = try encoder.encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let jsonObject = jsonObject as? [AnyHashable : Any] else {
                throw "encoded json object can not be casted to [AnyHashable : Any]".asError()
            }
            return jsonObject
        } catch {
            debugLog(error.localizedDescription)
            assert(false, error.localizedDescription)
            return [:]
        }
    }
}

// MARK: - Helper Functions

private func formatPaymentAmountType(_ type: PaymentAmountType) -> String {
    switch type {
    case .fixed:
        return "FIXED"
    case .variable:
        return "VARIABLE"
    }
}

private func formatPeriodUnit(_ unit: PeriodUnit) -> String {
    switch unit {
    case .day:
        return "DAY"
    case .week:
        return "WEEK"
    case .month:
        return "MONTH"
    case .year:
        return "YEAR"
    }
}

private func formatDate(_ date: Date?) -> String? {
    guard let date = date else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
