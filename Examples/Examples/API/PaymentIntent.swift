//
//  PaymentIntentInfo.swift
//  Examples
//
//  Created by Weiping Li on 10/12/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

/// https://www.airwallex.com/docs/api?v=2021-11-25#/Payment_Acceptance/Payment_Intents/_api_v1_pa_payment_intents__id_/get
struct PaymentIntent: Decodable {
    let id: String
    let status: String
    let latestPaymentAttempt: PaymentAttempt?
}
