//
//  PaymentConsentOptions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/8/18.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

/// Options for payment consents
@objc
public final class PaymentConsentOptions: NSObject {
    /// The party to trigger subsequent payments. One of `merchant`, `customer`.
    @objc public let nextTriggeredBy: AirwallexNextTriggerByType
    
    /// indicate whether the subsequent payments are scheduled.
    /// Only applicable when next_triggered_by is merchant. One of `.undefined`, `scheduled`, `unscheduled`, `installments`. Default: `.undefined`
    @objc public let merchantTriggerReason: AirwallexMerchantTriggerReason
    
    /// Terms to specify how this Payment Consent will be used.
    /// Optional.
    @objc public let termsOfUse: TermsOfUse?
    
    /// Creates a new payment consent options instance for recurring payments.
    ///
    /// - Parameters:
    ///   - nextTriggeredBy: Specifies which party will trigger subsequent payments.
    ///                      Use `.merchantType` when merchant initiates future payments,
    ///                      or `.customerType` when customer initiates future payments.
    ///   - merchantTriggerReason: Indicates whether subsequent payments are scheduled.
    ///                           Only applicable when nextTriggeredBy is `.merchantType`.
    ///                           Default value is `.undefined`.
    ///   - termsOfUse: Terms to specify how this Payment Consent will be used.
    @objc public init(nextTriggeredBy: AirwallexNextTriggerByType,
                      merchantTriggerReason: AirwallexMerchantTriggerReason = .undefined,
                      termsOfUse: TermsOfUse? = nil) {
        self.nextTriggeredBy = nextTriggeredBy
        self.merchantTriggerReason = merchantTriggerReason
        self.termsOfUse = termsOfUse
    }
    
    func validate() throws {
        switch nextTriggeredBy {
        case .customerType:
            guard merchantTriggerReason == .undefined else {
                throw "merchant trigger reason should be .undefined for CIT recurring options".asError()
            }
        case .merchantType:
            break
        }
    }
}

extension PaymentConsentOptions: Encodable {
    enum CodingKeys: String, CodingKey {
        case nextTriggeredBy
        case merchantTriggerReason
        case termsOfUse
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(FormatNextTriggerByType(nextTriggeredBy), forKey: .nextTriggeredBy)
        if nextTriggeredBy == AirwallexNextTriggerByType.merchantType,
           let reason = FormatMerchantTriggerReason(merchantTriggerReason) {
            try container.encode(reason, forKey: .merchantTriggerReason)
        }
        try container.encodeIfPresent(termsOfUse, forKey: .termsOfUse)
    }
}

extension PaymentConsentOptions: AWXJSONEncodable {
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
