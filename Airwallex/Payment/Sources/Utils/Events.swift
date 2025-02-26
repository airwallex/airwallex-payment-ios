//
//  Events.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexRisk
#if canImport(Core)
import Core
#endif

enum AnalyticEvent {
    
    enum Fields: String {
        case subtype = "subtype"
        case intentId = "intent_id"
        case paymentMethod = "payment_method"
        case consentId = "consent_id"
        case supportedSchemes = "supportedSchemes"
        case bankName = "bankName"
        case message = "message"
        case value = "value"
    }
    
    enum PageView: String {
        case paymentMethodList = "payment_method_list"
    }
    
    struct PaymentMethodView: RawRepresentable {
        static let applePay = PaymentMethodView(rawValue: AWXApplePayKey)
        static let card = PaymentMethodView(rawValue: AWXCardKey)
        
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    enum Action: String {
        case selectPayment = "select_payment"
        case tapPayButton = "tap_pay_button"
        case cardPaymentValidation = "card_payment_validation"
        case toggleBillingAddress = "toggle_billing_address"
        case saveCard = "save_card"
        case selectBank = "select_bank"
        case paymentLaunched = "payment_launched"
        case paymentCanceled = "payment_canceled"
    }
}

extension AnalyticsLogger {
    static func log(pageView name: AnalyticEvent.PageView, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        if let extraInfo {
            shared().logPageView(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            shared().logPageView(withName: name.rawValue)
        }
    }
    
    static func log(action name: AnalyticEvent.Action, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        if let extraInfo {
            shared().logAction(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            shared().logAction(withName: name.rawValue)
        }
    }
    
    static func log(paymentMethodView name: String, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        log(paymentMethodView: AnalyticEvent.PaymentMethodView(rawValue: name), extraInfo: extraInfo)
    }
    
    static func log(paymentMethodView name: AnalyticEvent.PaymentMethodView, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        if let extraInfo {
            shared().logPaymentMethodView(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            shared().logPaymentMethodView(withName: name.rawValue)
        }
    }
}

enum RiskEvent: String {
    enum Page: String {
        case consent = "page_consent"
        case createCard = "page_create_card"
    }
    
    case showCreateCard = "show_create_card"
    case showConsent = "show_consent"
    
    case inputCardNumber = "input_card_number"
    case inputCardExpiry = "input_card_expiry"
    case inputCardCVC = "input_card_cvc"
    case inputCardHolderName = "input_card_holder_name"
    case clickPaymentButton = "click_payment_button"
}

enum RiskLogger {
    static func log(_ event: RiskEvent, screen: RiskEvent.Page?) {
        Risk.log(event: event.rawValue, screen: screen?.rawValue)
    }
}
