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
        case intentId = "intentId"
        case paymentMethod = "paymentMethod"
        case consentId = "consentId"
        case supportedSchemes = "supportedSchemes"
        case bankName = "bankName"
        case message = "message"
        case value = "value"
        case eventType = "eventType"
        case supportedNetworks = "supportedNetworks"
        case expressCheckout = "expressCheckout"// boolean value
    }
    
    @_spi(AWX) public enum PageView: String {
        case paymentMethodList = "payment_method_list"
        case applePaySheet = "apple_pay_sheet"
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
        case paymentSuccess = "payment_success"
    }
}

public protocol ErrorLoggable: LocalizedError, CustomNSError {
    var eventName: String { get }
    var eventType: String? { get }
}

extension ErrorLoggable {
    var eventType: String? { return nil }
}

@_spi(AWX) public extension AnalyticsLogger {
    static func log(pageView name: AnalyticEvent.PageView, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        guard !ProcessInfo.isRunningUnitTest else { return }
        let (name, additionalInfo) = processEventInfo(event: name, extraInfo: extraInfo)
        shared().logPageView(withName: name, additionalInfo: additionalInfo)
    }
    
    static func log(action name: AnalyticEvent.Action, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        guard !ProcessInfo.isRunningUnitTest else { return }
        let (name, additionalInfo) = processEventInfo(event: name, extraInfo: extraInfo)
        shared().logAction(withName: name, additionalInfo: additionalInfo)
    }
    
    static func log(paymentMethodView name: String, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        guard !ProcessInfo.isRunningUnitTest else { return }
        log(paymentMethodView: AnalyticEvent.PaymentMethodView(rawValue: name), extraInfo: extraInfo)
    }
    
    static func log(paymentMethodView name: AnalyticEvent.PaymentMethodView, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        guard !ProcessInfo.isRunningUnitTest else { return }
        let (name, additionalInfo) = processEventInfo(event: name, extraInfo: extraInfo)
        shared().logPaymentMethodView(withName: name, additionalInfo: additionalInfo)
    }
    
    static func log(error: ErrorLoggable, extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        guard !ProcessInfo.isRunningUnitTest else { return }
        let (name, additionalInfo) = processErrorInfo(error: error, extraInfo: extraInfo)
        shared().logError(withName: name, additionalInfo: additionalInfo)
    }
    
    static func log(errorName: String,
                    errorType: String? = nil,
                    errorMessage: String? = nil,
                    extraInfo: [AnalyticEvent.Fields : Any]? = nil) {
        guard !ProcessInfo.isRunningUnitTest else { return }
        var infoDict = [String: Any]()
        if let errorType {
            infoDict[AnalyticEvent.Fields.eventType.rawValue] = errorType
        }
        if let errorMessage {
            infoDict[AnalyticEvent.Fields.message.rawValue] = errorMessage
        }
        if let extraInfo {
            for keyValuePair in extraInfo {
                infoDict[keyValuePair.key.rawValue] = keyValuePair.value
            }
        }
        shared().logError(withName: errorName, additionalInfo: infoDict)
    }
    
    static func processEventInfo<T: RawRepresentable<String>>(event: T, extraInfo: [AnalyticEvent.Fields: Any]?) -> (String, [String: Any]) {
        var processedInfo = [String: Any]()
        if let extraInfo {
            for (k, v) in extraInfo {
                processedInfo[k.rawValue] = v
            }
        }
        return (event.rawValue, processedInfo)
    }
    
    static func processErrorInfo(error: ErrorLoggable, extraInfo: [AnalyticEvent.Fields: Any]?) -> (String, [String: Any]) {
        var dict = [String: Any]()
        dict[AnalyticEvent.Fields.message.rawValue] = error.localizedDescription
        dict[AnalyticEvent.Fields.eventType.rawValue] = error.eventType
        if let extraInfo {
            for keyValuePair in extraInfo {
                dict[keyValuePair.key.rawValue] = keyValuePair.value
            }
        }
        return (error.eventName, dict)
    }
}

@_spi(AWX) public enum RiskEvent: String {
    @_spi(AWX) public enum Page: String {
        case consent = "page_consent"
        case createCard = "page_create_card"
        case applePay = "page_apple_pay"
    }
    
    case showApplePay = "show_apple_pay"
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
        guard !ProcessInfo.isRunningUnitTest else { return }
        Risk.log(event: event.rawValue, screen: screen?.rawValue)
    }
}

extension ProcessInfo {
    static var isRunningUnitTest: Bool {
        processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
    
