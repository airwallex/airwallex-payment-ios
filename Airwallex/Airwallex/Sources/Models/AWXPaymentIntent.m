//
//  AWXPaymentIntent.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/3/31.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentIntent.h"

@implementation AWXPaymentIntent

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentIntent *intent = [AWXPaymentIntent new];
    intent.Id = json[@"id"];
    NSNumber *amount = json[@"amount"];
    intent.amount = [NSDecimalNumber decimalNumberWithDecimal:amount.decimalValue];
    intent.currency = json[@"currency"];
    intent.status = json[@"status"];
    intent.availablePaymentMethodTypes = json[@"available_payment_method_types"];
    intent.clientSecret = json[@"client_secret"];
    intent.customerId = json[@"customer_id"];
    return intent;
}

@end
