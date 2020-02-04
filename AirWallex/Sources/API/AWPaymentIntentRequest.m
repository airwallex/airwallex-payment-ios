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
    [parameters addEntriesFromDictionary:@{@"request_id": self.requestId,
                                           @"device": @{@"browser_info": @"Chrome/76.0.3809.100",
                                                        @"cookies_accepted": @"true",
                                                        @"device_id": [UIDevice currentDevice].identifierForVendor.UUIDString,
                                                        @"host_name": @"www.airwallex.com",
                                                        @"http_browser_email": @"jim631@sina.com",
                                                        @"http_browser_type": @"chrome",
                                                        @"ip_address": @"123.90.0.1",
                                                        @"ip_network_address": @"128.0.0.0"
                                           }
    }];
    if (self.paymentMethod.Id) {
        [parameters addEntriesFromDictionary:@{
            @"payment_method_reference": @{
                    @"id": self.paymentMethod.Id,
                    @"cvc": self.paymentMethod.card.cvc ?: @"123" // Fake cvc (UI required)
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
                            @"three_ds": @{@"option": @(self.options.threeDsOption), @"pa_res": self.options.threeDsPaRes}
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
