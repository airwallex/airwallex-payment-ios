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
#import "AWPaymentMethodOptions.h"
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
    if (self.paymentMethod.Id) {
        [parameters addEntriesFromDictionary:@{
            @"payment_method_reference": @{
                    @"id": self.paymentMethod.Id,
                    @"cvc": self.paymentMethod.card.cvc ?: @""
            }
        }];
    } else {
        [parameters addEntriesFromDictionary:@{@"payment_method": self.paymentMethod.toJSONDictionary}];
    }
    if (self.options) {
        [parameters addEntriesFromDictionary:@{
            @"payment_method_options": @{
                    @"card": @{
                            @"auto_capture": @(self.options.autoCapture),
                            @"three_ds": @{@"option": @(self.options.threeDsOption)}
                    }
            }
        }];
    }
    return parameters;
}

- (Class)responseClass
{
    return AWConfirmPaymentIntentResponse.class;
}

@end

@implementation AWGetPaymentIntentRequest

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
