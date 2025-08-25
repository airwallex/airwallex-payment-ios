//
//  RecurringOptions.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/8/18.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

/// Options for recurring payments
@objc
public final class RecurringOptions: NSObject {
    /// The party to trigger subsequent payments. One of `merchant`, `customer`.
    public let nextTriggeredBy: AirwallexNextTriggerByType
    
    /// indicate whether the subsequent payments are scheduled.
    /// Only applicable when next_triggered_by is merchant. One of `scheduled`, `unscheduled`, `installments`. Default: `unscheduled`
    public let merchantTriggerReason: AirwallexMerchantTriggerReason?
    
    public init(nextTriggeredBy: AirwallexNextTriggerByType,
         merchantTriggerReason: AirwallexMerchantTriggerReason? = nil) {
        self.nextTriggeredBy = nextTriggeredBy
        self.merchantTriggerReason = merchantTriggerReason
    }
}

extension RecurringOptions: Encodable {
    enum CodingKeys: String, CodingKey {
        case nextTriggeredBy
        case merchantTriggerReason
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(FormatNextTriggerByType(nextTriggeredBy), forKey: .nextTriggeredBy)
        if nextTriggeredBy == AirwallexNextTriggerByType.merchantType,
           let merchantTriggerReason,
           let reason = FormatMerchantTriggerReason(merchantTriggerReason) {
            try container.encode(reason, forKey: .merchantTriggerReason)
        }
    }
}

extension RecurringOptions: AWXJSONEncodable {
    public func encodeToJSON() -> [AnyHashable : Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable : Any] else {
            assert(false, "something is wrong in data encoding")
            return [:]
        }
        return jsonObject
    }
}
