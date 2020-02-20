//
//  AWPaymentMethod.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethod.h"

@implementation AWPaymentMethod

- (NSDictionary *)toJSONDictionary
{
    NSMutableDictionary *items = [[NSMutableDictionary alloc] init];
    items[@"type"] = self.type;
    if (self.billing) {
        items[@"billing"] = self.billing.toJSONDictionary;
    }
    if (self.card) {
        items[@"card"] = self.card.toJSONDictionary;
    }
    if (self.wechatpay) {
        items[@"wechatpay"] = self.wechatpay.toJSONDictionary;
    }
    return items;
}

+ (id)parseFromJsonDictionary:(NSDictionary *)json
{
    AWPaymentMethod *method = [AWPaymentMethod new];
    method.Id = json[@"id"];
    method.type = json[@"type"];
    NSDictionary *card = json[@"card"];
    if (card) {
        method.card = [AWCard parseFromJsonDictionary:card];
    }
    NSDictionary *wechatpay = json[@"wechatpay"];
    if (wechatpay) {
        method.wechatpay = [AWWechatPay parseFromJsonDictionary:wechatpay];
    }
    method.billing = [AWBilling parseFromJsonDictionary:json[@"billing"]];
    return method;
}

@end
