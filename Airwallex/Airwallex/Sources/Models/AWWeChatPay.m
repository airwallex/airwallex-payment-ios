//
//  AWWeChatPay.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWWeChatPay.h"

@implementation AWWeChatPay

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
    AWWeChatPay *pay = [AWWeChatPay new];
    pay.flow = json[@"flow"];
    return pay;
}

@end
