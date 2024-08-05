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
public class AWXConfirmPaymentIntentConfiguration: NSObject {
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

    public var parameters: [String: Any] {
        var parameters = [String: Any]()
        parameters["request_id"] = requestId
        if let customerId = customerId {
            parameters["customer_id"] = customerId
        }

        if let paymentConsent = paymentConsent, let Id = paymentConsent.Id {
            let consentParams = [
                "id": Id,
                "cvc": paymentMethod?.card?.cvc ?? "",
            ]
            parameters["payment_consent_reference"] = consentParams
        } else {
            if let Id = paymentMethod?.Id {
                parameters["payment_method_reference"] = [
                    "id": Id,
                    "cvc": paymentMethod?.card?.cvc ?? "",
                ]
            } else {
                parameters["payment_method"] = paymentMethod?.toDictionary()
            }
        }
        if let options = options {
            parameters["payment_method_options"] = options.toDictionary()
        }
        if let returnURL = returnURL {
            parameters["return_url"] = returnURL
        }
        parameters["save_payment_method"] = savePaymentMethod
        if let device = device {
            parameters["device_data"] = device.toDictionary()
        }
        parameters["integration_data"] = [
            "type": "mobile_sdk",
            "version": "ios-release-\(AIRWALLEX_VERSION)",
        ]
        return parameters
    }
}
