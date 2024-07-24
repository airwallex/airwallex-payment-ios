//
//  AWXPaymentMethodType.swift
//  Core
//
//  Created by Tony He (CTR) on 2024/7/23.
//  Copyright © 2024 Airwallex. All rights reserved.
//

import Foundation

/**
 `AWXPaymentMethodType` includes the information of a payment method.
 */
@objcMembers
@objc(AWXPaymentMethodTypeSwift)
public class AWXPaymentMethodType: NSObject, Codable {
    
    /**
     name of the payment method.
     */
    public var name: String?

    /**
     display name of the payment method.
     */
    public var displayName: String?

    /**
     transaction_mode of the payment method. One of oneoff, recurring.
     */
    public var transactionMode: String?

    /**
     flows of the payment method.
     */
    public var flows: [String] = []

    /**
     transaction_currencies of the payment method.  "*", "AUD", "CHF", "HKD", "SGD", "JPY", "EUR", "GBP", "USD", "CAD", "NZD", "CNY"
     */
    public var transactionCurrencies: [String] = []

    /**
     Whether payment method is active.
     */
    public var active: Bool = false

    /**
     Resources
     */
    public var resources: AWXResources?

    /**
     Whether it has schema
     */
    public var hasSchema: Bool = false

    /**
     Supported card schemes
     */
    public var cardSchemes: [AWXCardScheme] = []

}

/**
 `AWXResources` includes the resources of payment method.
 */
@objcMembers
@objc(AWXResourcesSwift)
public class AWXResources: NSObject, Codable {
   
    /**
     Logo url
     */
    public var logoURL: URL?

    /**
     has_schema
     */
    public var hasSchema: Bool = false
}

@objcMembers
@objc(AWXCardSchemeSwift)
public class AWXCardScheme: NSObject, Codable {
    
    public var name: String = ""
}
