//
//  AWXAPIClient.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/19.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

@objcMembers
@objc(AWXAPIClientSwift)
public class AWXAPIClient: NSObject {
    public static func confirmPaymentIntentWithConfiguration(
        _ configuration: AWXConfirmPaymentIntentConfiguration,
        completion: @escaping (AWXConfirmPaymentIntentResponse?, Error?) -> Void
    ) {
        if [AWXCardKey, AWXApplePayKey].contains(configuration.paymentMethod?.type) {
            let cardOptions: AWXCardOptions
            if configuration.paymentMethod?.type == AWXCardKey {
                let threeDs = AWXThreeDs(paRes: nil, returnURL: AWXThreeDSReturnURL, attemptId: nil, deviceDataCollectionRes: nil, dsTransactionId: nil)
                cardOptions = AWXCardOptions(autoCapture: configuration.autoCapture, threeDs: threeDs)
            } else {
                cardOptions = AWXCardOptions(autoCapture: configuration.autoCapture, threeDs: nil)
            }
            let options = AWXPaymentMethodOptions(cardOptions: cardOptions)
            configuration.options = options
        }

        AWXNetWorkManager().post(
            path: configuration.path, payload: configuration, eventName: "confirm_payment_intent"
        ) { (result: Result<AWXConfirmPaymentIntentResponse, Error>) in
            switch result {
            case let .success(response):
                completion(response, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    public static func getAvailablePaymentMethodsWithConfiguration(
        _ configuration: AWXGetPaymentMethodTypesConfiguration,
        completion: @escaping (AWXGetPaymentMethodTypesResponse?, Error?) -> Void
    ) {
        AWXNetWorkManager().get(path: configuration.path, parameters: configuration.parameters, eventName: "get_available_payment_methods") { (result: Result<AWXGetPaymentMethodTypesResponse, Error>) in
            switch result {
            case let .success(response):
                completion(response, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
}
