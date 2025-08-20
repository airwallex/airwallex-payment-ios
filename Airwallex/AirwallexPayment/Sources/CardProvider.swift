//
//  CardProvider.swift
//  AirwallexPayment
//
//  Created by Weiping Li on 20/8/25.
//  Copyright © 2025 Airwallex. All rights reserved.
//

#if canImport(AirwallexCore)
import AirwallexCore
#endif
import Foundation

@_spi(AWX) public class CardPaymentProvider: PaymentProvider {
    
    public override class func canHandle(_ session: AWXSession, paymentMethod: AWXPaymentMethodType) -> Bool {
        paymentMethod.cardSchemes.count != 0
    }
    
    func confirmIntent(with card: AWXCard, billing: AWXPlaceDetails? = nil, saveCard: Bool) {
        debugLog("Start payment confirm. Type: Card. Intent Id: \(unifiedSession.paymentIntent.id)")
        var method = AWXPaymentMethod()
        method.type = AWXCardKey
        method.billing = billing
        method.card = card
        method.customerId = unifiedSession.paymentIntent.customerId
        delegate?.providerDidStartRequest(self)
        
        if saveCard && unifiedSession.paymentIntent.customerId != nil {
            unifiedSession.recurringOptions = RecurringOptions(nextTriggeredBy: .customerType)
        }
        confirmInitialTransaction(method)
    }
}
