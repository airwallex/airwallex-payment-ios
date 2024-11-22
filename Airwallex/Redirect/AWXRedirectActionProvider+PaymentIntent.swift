//
//  AWXRedirectActionProvider+PaymentIntent.swift
//  Redirect
//
//  Created by Hector.Huang on 2024/9/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

public extension AWXRedirectActionProvider {
    @objc(confirmPaymentIntentWithPaymentMethodName:additionalInfo:flow:)
    func confirmPaymentIntent(
        with paymentMethodName: String,
        additionalInfo: Dictionary<String, String>? = nil,
        flow: AWXPaymentMethodFlow = .app
    ) {
        let paymentMethod = AWXPaymentMethod()
        paymentMethod.type = paymentMethodName
        paymentMethod.additionalParams = additionalInfo
        confirmPaymentIntent(with: paymentMethod, paymentConsent: nil, flow: flow)
    }
}
