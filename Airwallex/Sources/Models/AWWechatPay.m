//
//  AWWechatPay.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWWechatPay.h"

@implementation AWWechatPay

- (NSDictionary *)toJSONDictionary
{
    return @{@"flow": self.flow};
}

+ (id)parseFromJsonDictionary:(NSDictionary *)json
{
    AWWechatPay *pay = [AWWechatPay new];
    pay.flow = json[@"flow"];
    return pay;
}

@end
