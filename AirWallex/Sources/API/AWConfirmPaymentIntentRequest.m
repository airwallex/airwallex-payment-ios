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
    return AWHTTPMethodPOST;
}

- (NSDictionary *)parameters
{
    return @{@"payment_method": self.paymentMethod.toJSONDictionary,
             @"request_id": self.requestId
    };
}

- (Class)responseClass
{
    return AWConfirmPaymentintentResponse.class;
}

@end
