//
//  AWConfirmPaymentIntentRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWConfirmPaymentIntentRequest.h"
#import "AWPaymentMethod.h"
#import "AWPaymentMethodOptions.h"
#import "AWConfirmPaymentintentResponse.h"

@implementation AWConfirmPaymentIntentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@/confirm", self.intentId];
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodGET;
}

- (NSDictionary *)parameters
{
    return @{@"customer_id": self.customerId,
             @"payment_method": self.paymentMethod.toJSONDictionary,
             @"payment_method_option": self.paymentMethodOptions.toJSONDictionary,
             @"request_id": self.requestId,
             @"save_payment_method": self.savePaymentMethod ? @"true" : @"false"
    };
}

- (Class)responseClass
{
    return AWConfirmPaymentintentResponse.class;
}

@end
