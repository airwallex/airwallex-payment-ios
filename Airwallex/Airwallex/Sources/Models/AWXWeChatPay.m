//
//  AWXWeChatPay.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXWeChatPay.h"

@implementation AWXWeChatPay

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.flow = @"inapp";
    }
    return self;
}

- (NSDictionary *)encodeToJSON
{
    return @{@"flow": self.flow};
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXWeChatPay *pay = [AWXWeChatPay new];
    pay.flow = json[@"flow"];
    return pay;
}

@end
