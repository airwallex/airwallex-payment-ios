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
    return @{
        @"card": @{
                @"auto_capture": self.autoCapture ? @"true" : @"false",
                @"three_ds": @{
                        @"option": self.threeDsOption ? @"true" : @"false"
                }
        }
    };
}

@end
