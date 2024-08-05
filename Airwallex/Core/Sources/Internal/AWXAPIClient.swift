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
    
    public static func confirmPaymentIntentWithIntentId(_ PaymentIntentId: String,
                                                        configuration: AWXConfirmPaymentIntentConfiguration,
                                                        completion: @escaping (Bool, AWXConfirmPaymentIntentResponse?, Error?) -> Void) {
        
        if [AWXCardKey, AWXApplePayKey].contains(configuration.paymentMethod?.type) {
            let cardOptions = AWXCardOptions()
            cardOptions.autoCapture = configuration.autoCapture
            if configuration.paymentMethod?.type == AWXCardKey {
                let threeDs = AWXThreeDs()
                threeDs.returnURL = AWXThreeDSReturnURL
                cardOptions.threeDs = threeDs
            }
            
            let options = AWXPaymentMethodOptions()
            options.cardOptions = cardOptions
            configuration.options = options
        }
        
        AWXNetWorkManager.shared.post(urlString: configuration.path, parameters: configuration.parameters) { (result: Result<AWXConfirmPaymentIntentResponse, Error>) in
            switch result {
            case .success(let response):
                completion(true, response, nil)
            case .failure(let error):
                completion(false, nil, error)
            }
        }
    }
    
}
