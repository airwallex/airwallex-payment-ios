//
//  AWXConfirmPaymentIntentConfiguration.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/22.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objcMembers
@objc
public class AWXConfirmPaymentIntentConfiguration: NSObject, Encodable {
    public var intentId: String = ""
    public let requestId: String = UUID().uuidString
    public var customerId: String?
    public var paymentConsent: AWXPaymentConsent?
    public var paymentMethod: AWXPaymentMethod?
    public var options: AWXPaymentMethodOptions?
    public var returnURL: String?
    public var savePaymentMethod: Bool = false
    public var autoCapture: Bool = false
    public var device: AWXDevice?

    public var path: String {
        "api/v1/pa/payment_intents/\(intentId)/confirm"
    }

    private enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case customerId = "customer_id"
        case paymentConsentReference = "payment_consent_reference"
        case paymentMethodReference = "payment_method_reference"
        case paymentMethod = "payment_method"
        case options = "payment_method_options"
        case returnURL = "return_url"
        case savePaymentMethod = "save_payment_method"
        case deviceData = "device_data"
        case integrationData = "integration_data"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(requestId, forKey: .requestId)
        try container.encodeIfPresent(customerId, forKey: .customerId)

        if let paymentConsent = paymentConsent, let id = paymentConsent.id {
            try container.encode(["id": id, "cvc": paymentMethod?.card?.cvc ?? ""], forKey: .paymentConsentReference)
        } else if let id = paymentMethod?.id {
            try container.encode(["id": id, "cvc": paymentMethod?.card?.cvc ?? ""], forKey: .paymentMethodReference)
        } else {
            try container.encode(paymentMethod, forKey: .paymentMethod)
        }

        try container.encode(options, forKey: .options)
        try container.encode(returnURL, forKey: .returnURL)
        try container.encode(savePaymentMethod, forKey: .savePaymentMethod)
        try container.encode(device, forKey: .deviceData)

        let integrationData = [
            "type": "mobile_sdk",
            "version": "ios-release-\(AIRWALLEX_VERSION)",
        ]
        try container.encode(integrationData, forKey: .integrationData)
    }
}
