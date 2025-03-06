//
//  Events.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexRisk

struct AnalyticEvent {
    
    private init() {}
    struct Fields: RawRepresentable, Hashable {
        static let subType = Fields(rawValue: "subtype")
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
        static let launchPayment = Action(rawValue: "launch_payment")
        static let paymentCanceled = Action(rawValue: "payment_canceled")
        
        let rawValue: String
        init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension AnalyticEvent {
    static func log(pageView name: AnalyticEvent.PageView, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
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
    
    static func log(action name: AnalyticEvent.Action, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
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
    
    static func log(paymentView name: String, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        log(paymentView: AnalyticEvent.PaymentView(rawValue: name), extraInfo: extraInfo)
    }
    
    static func log(paymentView name: AnalyticEvent.PaymentView, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        if let extraInfo {
            AWXAnalyticsLogger.shared().logPaymentMethodView(
                withName: name.rawValue,
                additionalInfo: extraInfo.reduce(into: [String: Any]()) { partialResult, keyValuePair in
                    partialResult[keyValuePair.key.rawValue] = keyValuePair.value
                }
            )
        } else {
            AWXAnalyticsLogger.shared().logPaymentMethodView(withName: name.rawValue)
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
    case pageCreateCard = "page_create_card"
    
    case inputCardNumber = "input_card_number"
    case inputCardExpiry = "input_card_expiry"
    case inputCardCVC = "input_card_cvc"
    case inputCardHolderName = "input_card_holder_name"
    case clickPaymentButton = "click_payment_button"
    
    static func log(_ event: RiskEvent, screen: RiskEvent.Page?) {
        Risk.log(event: event.rawValue, screen: screen?.rawValue)
    }
}
