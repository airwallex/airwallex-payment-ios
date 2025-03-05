//
//  Events.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation

struct Event {
    
    private init() {}
    struct Fields: RawRepresentable, Hashable {
        static let subType = Fields(rawValue: "sub_type")
        static let intentId = Fields(rawValue: "intent_id")
        static let paymentMethod = Fields(rawValue: "payment_method")
        
        static let consentId = Fields(rawValue: "consent_id")
        static let supportedSchemes = Fields(rawValue: "supportedSchemes")
        static let bankName = Fields(rawValue: "bankName")
        static let message = Fields(rawValue: "message")
        static let value = Fields(rawValue: "value")
        
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    struct PageView: RawRepresentable {
        static let paymentMethodList = PageView(rawValue: "payment_method_list")
        
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    struct PaymentView: RawRepresentable {
        static let applePay = PaymentView(rawValue: AWXApplePayKey)
        static let card = PaymentView(rawValue: AWXCardKey)
        
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    struct Action: RawRepresentable {
        static let selectPayment = Action(rawValue: "select_payment")
        static let tapPayButton = Action(rawValue: "tap_pay_button")
        static let cardPaymentValidation = Action(rawValue: "card_payment_validation")
        static let toggleBillingAddress = Action(rawValue: "toggle_billing_address")
        static let saveCard = Action(rawValue: "save_card")
        static let selectBank = Action(rawValue: "select_bank")
        static let launchPayment = Action(rawValue: "launchPayment")
        
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Event {
    static func log(pageView name: Event.PageView, extraInfo: [Event.Fields : Any]? = nil) {
        if let extraInfo {
            AWXAnalyticsLogger.shared().logPageView(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            AWXAnalyticsLogger.shared().logPageView(withName: name.rawValue)
        }
    }
    
    static func log(action name: Event.Action, extraInfo: [Event.Fields : Any]? = nil) {
        if let extraInfo {
            AWXAnalyticsLogger.shared().logAction(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            AWXAnalyticsLogger.shared().logAction(withName: name.rawValue)
        }
    }
    
    static func log(paymentView name: String, extraInfo: [Event.Fields : Any]? = nil) {
        log(paymentView: Event.PaymentView(rawValue: name), extraInfo: extraInfo)
    }
    
    static func log(paymentView name: Event.PaymentView, extraInfo: [Event.Fields : Any]? = nil) {
        if let extraInfo {
            AWXAnalyticsLogger.shared().logPaymentView(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            AWXAnalyticsLogger.shared().logPaymentView(withName: name.rawValue)
        }
    }
}
