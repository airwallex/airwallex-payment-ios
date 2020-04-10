//
//  AWPaymentMethod.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentMethod.h"

@implementation AWPaymentMethod

- (NSDictionary *)encodeToJSON
{
    NSMutableDictionary *items = [[NSMutableDictionary alloc] init];
    items[@"type"] = self.type;
    if (self.billing) {
        items[@"billing"] = self.billing.encodeToJSON;
    }
    if (self.card) {
        items[@"card"] = self.card.encodeToJSON;
    }
    if (self.weChatPay) {
        items[@"wechatpay"] = self.weChatPay.encodeToJSON;
    }
    if (self.customerId) {
        items[@"customer_id"] = self.customerId;
    }
    return items;
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWPaymentMethod *method = [AWPaymentMethod new];
    method.Id = json[@"id"];
    method.type = json[@"type"];
    NSDictionary *card = json[@"card"];
    if (card) {
        method.card = [AWCard decodeFromJSON:card];
    }
    NSDictionary *weChatPay = json[@"wechatpay"];
    if (weChatPay) {
        method.weChatPay = [AWWeChatPay decodeFromJSON:weChatPay];
    }
    method.billing = [AWPlaceDetails decodeFromJSON:json[@"billing"]];
    method.customerId = json[@"customer_id"];
    return method;
}

@end
