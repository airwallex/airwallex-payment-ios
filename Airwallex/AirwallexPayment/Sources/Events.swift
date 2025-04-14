//
//  Events.swift
//  Airwallex
//
//  Created by Weiping Li on 2025/3/5.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
import AirwallexRisk
#if canImport(AirwallexCore)
import AirwallexCore
#endif

@_spi(AWX) public enum AnalyticEvent {
    
    @_spi(AWX) public enum Fields: String {
        case subtype = "subtype"
        case intentId = "intent_id"
        case paymentMethod = "payment_method"
        case consentId = "consent_id"
        case supportedSchemes = "supportedSchemes"
        case bankName = "bankName"
        case message = "message"
        case value = "value"
        case eventType = "eventType"
    }
    
    @_spi(AWX) public enum PageView: String {
        case paymentMethodList = "payment_method_list"
    }
    
    @_spi(AWX) public struct PaymentMethodView: RawRepresentable {
        @_spi(AWX) public static let applePay = PaymentMethodView(rawValue: AWXApplePayKey)
        @_spi(AWX) public static let card = PaymentMethodView(rawValue: AWXCardKey)
        
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    @_spi(AWX) public enum Action: String {
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

public protocol ErrorLoggable: LocalizedError, CustomNSError {
    var eventName: String { get }
    var eventType: String? { get }
}

@_spi(AWX) public extension AnalyticsLogger {
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
    
    static func log(error: ErrorLoggable, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        var dict = [String: Any]()
        dict[AnalyticEvent.Fields.message.rawValue] = error.localizedDescription
        if let extraInfo {
            for keyValuePair in extraInfo {
                dict[keyValuePair.key.rawValue] = keyValuePair.value
            }
        }
        
        shared().logError(
            withName: error.eventName,
            additionalInfo: dict
        )
    }
}

@_spi(AWX) public enum RiskEvent: String {
    @_spi(AWX) public enum Page: String {
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

@_spi(AWX) public enum RiskLogger {
    @_spi(AWX) public
    static func log(_ event: RiskEvent, screen: RiskEvent.Page?) {
        Risk.log(event: event.rawValue, screen: screen?.rawValue)
    }
}
