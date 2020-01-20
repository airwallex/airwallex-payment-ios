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
             @"request_id": self.requestId,
             @"device": @{@"browser_info": @"Chrome/76.0.3809.100",
                          @"cookies_accepted": @"true",
                          @"device_id": [UIDevice currentDevice].identifierForVendor.UUIDString,
                          @"host_name": @"www.airwallex.com",
                          @"http_browser_email": @"jim631@sina.com",
                          @"http_browser_type": @"chrome",
                          @"ip_address": @"123.90.0.1",
                          @"ip_network_address": @"128.0.0.0"
             }
    };
}

- (Class)responseClass
{
    return AWConfirmPaymentintentResponse.class;
}

@end
