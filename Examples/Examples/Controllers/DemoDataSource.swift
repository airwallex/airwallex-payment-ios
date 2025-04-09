//
//  DemoDataSource.swift
//  Examples
//
//  Created by Weiping Li on 2025/2/13.
//  Copyright © 2025 Airwallex. All rights reserved.
//

import Foundation
#if canImport(Airwallex)
import Airwallex
#elseif canImport(AirwallexPayment)
import AirwallexPayment
import AirwallexCore
#endif

struct DemoDataSource {
    
    static var testCard: AWXCard? {
        let cardNumber = [
            AirwallexSDKMode.demoMode : [
                CheckoutMode.oneOff : "4012000300000005",
                CheckoutMode.recurring : "4012000300000021",
                CheckoutMode.recurringWithIntent : "4012000300000005"
            ],
            AirwallexSDKMode.stagingMode: [
                CheckoutMode.oneOff : "4012000300001003",
                CheckoutMode.recurring : "4035501000000008",
                CheckoutMode.recurringWithIntent : "4012000300001003"
            ]
        ]
        
        guard let cardNumber = cardNumber[ExamplesKeys.environment]?[ExamplesKeys.checkoutMode] else {
            return nil
        }
        let card = AWXCard()
        card.number = cardNumber
        card.name = "John Citizen"
        card.expiryMonth = "12"
        card.expiryYear = "2029"
        card.cvc = "737"
        return card
    }
    
    static var testCard3DS: AWXCard? {
        
        let cardNumber = [
            AirwallexSDKMode.demoMode : [
                CheckoutMode.oneOff : "4012000300000088",
                CheckoutMode.recurring : "5425233430109903",
                CheckoutMode.recurringWithIntent : "4012000300000088"
            ],
            AirwallexSDKMode.stagingMode: [
                CheckoutMode.oneOff : "4012000300000088",
                CheckoutMode.recurring : "5307837360544518",
                CheckoutMode.recurringWithIntent : "4012000300000088"
            ]
        ]
        
        guard let cardNumber = cardNumber[ExamplesKeys.environment]?[ExamplesKeys.checkoutMode] else {
            return nil
        }
        let card = AWXCard()
        card.number = cardNumber
        card.name = "John Citizen"
        card.expiryMonth = "12"
        card.expiryYear = "2029"
        card.cvc = "737"
        return card
    }
    
    static var applePayOptions: AWXApplePayOptions {
        let options = AWXApplePayOptions(merchantIdentifier: applePayMerchantId)
        options.additionalPaymentSummaryItems = [
            .init(label: "goods", amount: NSDecimalNumber(value: products.count)),
            .init(label: "tax", amount: 1)
        ]
        options.totalPriceLabel = "COMPANY, INC."
        options.requiredBillingContactFields = [.postalAddress]
        return options
    }
    
    private static var applePayMerchantId: String {
        switch ExamplesKeys.environment {
        case .stagingMode:
            ""
        case .demoMode:
            "merchant.demo.com.airwallex.paymentacceptance"
        case .productionMode:
            "merchant.com.airwallex.paymentacceptance"
        }
    }
    
    static var shippingAddress: AWXPlaceDetails {
        let shipping: [String : Any] = [
            "first_name": "Jason",
            "last_name": "Wang",
            "phone_number": "13800000000",
            "email": "abc@123.com",
            "address": [
                "country_code": "CN",
                "state": "Shanghai",
                "city": "Shanghai",
                "street": "Pudong District",
                "postcode": "100000"
            ]
        ]
        return AWXPlaceDetails.decode(fromJSON: shipping) as! AWXPlaceDetails
    }
    
    static var products: [PhysicalProduct] {
        [
            .init(
                type: "Free engraving",
                code: "123",
                name: "AirPods Pro",
                sku: "piece",
                quantity: 1,
                unitPrice: 399,
                desc: "Buy AirPods Pro, per month with trade-in",
                url: "www.aircross.com"
            ),
            .init(
                type: "White",
                code: "123",
                name: "HomePod",
                sku: "piece",
                quantity: 1,
                unitPrice: 469,
                desc: "Buy HomePod, per month with trade-in",
                url: "www.aircross.com"
            )
        ]
    }
    
    static func createOrder(shipping: AWXPlaceDetails? = nil) -> PurchaseOrder {
        let shipping = shipping ?? shippingAddress
        let order = PurchaseOrder(
            products: products,
            shipping: .init(
                firstName: shipping.firstName,
                lastName: shipping.lastName,
                phoneNumber: shipping.phoneNumber,
                address: .init(
                    countryCode: shipping.address?.countryCode,
                    state: shipping.address?.state,
                    city: shipping.address?.city,
                    street: shipping.address?.street,
                    postcode: shipping.address?.postcode
                )
            ),
            type: "physical_goods"
        )
        return order
    }
    
    static let commentForLocalization = "Integration demo list"
    static let titleForPayAndSaveCard = NSLocalizedString("Pay with card and save card", comment: commentForLocalization)
    static let titleForForceCard3DS = NSLocalizedString("Pay with card and trigger 3DS", comment: commentForLocalization)
    static let titleForPayByRedirect = NSLocalizedString("Pay with Redirect", comment: commentForLocalization)
}
