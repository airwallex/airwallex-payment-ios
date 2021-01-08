//
//  AWXPaymentMethod.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentMethod.h"

@implementation AWXPaymentMethod

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
    if (self.nonCard) {
        items[self.nonCard.type] = self.nonCard.encodeToJSON;
    }
    if (self.customerId) {
        items[@"customer_id"] = self.customerId;
    }
    return items;
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentMethod *method = [AWXPaymentMethod new];
    method.Id = json[@"id"];
    method.type = json[@"type"];
    NSDictionary *card = json[@"card"];
    if (card) {
        method.card = [AWXCard decodeFromJSON:card];
    }
    NSDictionary *weChatPay = json[@"wechatpay"];
    if (weChatPay) {
        method.weChatPay = [AWXWeChatPay decodeFromJSON:weChatPay];
    }
    method.billing = [AWXPlaceDetails decodeFromJSON:json[@"billing"]];
    method.customerId = json[@"customer_id"];
    return method;
}

@end
