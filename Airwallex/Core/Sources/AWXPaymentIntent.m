//
//  AWXPaymentIntent.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/31.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentIntent.h"
#import "AWXPaymentMethod.h"
#ifdef AirwallexSDK
#import <Core/Core-Swift.h>
#else
#import <Airwallex/Airwallex-Swift.h>
#endif

@implementation AWXPaymentIntent

+ (id)decodeFromJSON:(NSDictionary *)json {
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    intent.Id = json[@"id"];
    NSNumber *amount = json[@"amount"];
    intent.amount = [NSDecimalNumber decimalNumberWithDecimal:amount.decimalValue];
    intent.currency = json[@"currency"];
    intent.status = json[@"status"];
    intent.availablePaymentMethodTypes = json[@"available_payment_method_types"];
    intent.clientSecret = json[@"client_secret"];
    intent.customerId = json[@"customer_id"];
    intent.paymentMethods = json[@"customer_payment_methods"];
    intent.paymentConsents = json[@"customer_payment_consents"];

    NSMutableArray *paymentMethods = [NSMutableArray array];
    NSArray *methods = json[@"customer_payment_methods"];
    if (methods && [methods isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in methods) {
            [paymentMethods addObject:[AWXPaymentMethod decodeFromJSON:item]];
        }
    }
    intent.paymentMethods = paymentMethods;

    NSMutableArray *paymentConsents = [NSMutableArray array];
    NSArray *consents = json[@"customer_payment_consents"];
    if (consents && [consents isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in consents) {
            [paymentConsents addObject:[AWXPaymentConsent decodeFromJSON:item]];
        }
    }
    intent.paymentConsents = paymentConsents;
    return intent;
}

@end
