//
//  AWPaymentMethodOptions.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethodOptions.h"

@implementation AWPaymentMethodOptions

- (NSDictionary *)toJSONDictionary
{
    NSMutableDictionary *threeDs = [@{
        @"option": self.threeDsOption ? @"true" : @"false"
    } mutableCopy];
    if (self.paRes) {
        threeDs[@"pa_res"] = self.paRes;
    }
    return @{
        @"card": @{
                @"auto_capture": self.autoCapture ? @"true" : @"false",
                @"three_ds": threeDs
        }
    };
}

@end
