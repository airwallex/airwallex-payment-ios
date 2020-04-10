//
//  AWPaymentIntentRequest.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWPaymentIntentRequest.h"
#import "AWPaymentMethod.h"
#import "AWPaymentIntentResponse.h"

@implementation AWConfirmPaymentIntentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@/confirm", self.intentId];
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodPOST;
}

- (nullable NSDictionary *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"request_id"] = self.requestId;
    if (self.customerId) {
        parameters[@"customer_id"] = self.customerId;
    }
    [parameters addEntriesFromDictionary:@{@"payment_method": self.paymentMethod.encodeToJSON}];
    return parameters;
}

- (Class)responseClass
{
    return AWConfirmPaymentIntentResponse.class;
}

@end

@implementation AWRetrievePaymentIntentRequest

- (NSString *)path
{
    return [NSString stringWithFormat:@"/api/v1/pa/payment_intents/%@", self.intentId];
}

- (AWHTTPMethod)method
{
    return AWHTTPMethodGET;
}

- (Class)responseClass
{
    return AWGetPaymentIntentResponse.class;
}

@end
