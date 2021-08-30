//
//  AWXPaymentConsent.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsent.h"
#import "AWXPaymentMethod.h"

@implementation AWXPaymentConsent

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentConsent *intent = [AWXPaymentConsent new];
    intent.Id = json[@"id"];
    intent.requestId = json[@"request_id"];
    intent.customerId = json[@"customer_id"];
    intent.status     = json[@"status"];
    intent.nextTriggeredBy = json[@"next_triggered_by"];
    intent.merchantTriggerReason = json[@"merchant_trigger_reason"];
    intent.requiresCVC = [json[@"requires_cvc"] boolValue];
    NSDictionary *paymentMethod = json[@"payment_method"];
    if (paymentMethod) {
        intent.paymentMethod = [AWXPaymentMethod decodeFromJSON:paymentMethod];
    }
    intent.createdAt = json[@"created_at"];
    intent.updatedAt = json[@"updated_at"];
    intent.clientSecret = json[@"client_secret"];
    return intent;
}

@end
