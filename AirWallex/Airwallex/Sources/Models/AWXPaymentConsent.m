//
//  AWXPaymentConsent.m
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsent.h"
#import "AWXPaymentMethod.h"

@interface AWXPaymentConsent ()

@property (nonatomic, copy, readwrite) NSString *Id;
@property (nonatomic, copy, readwrite) NSString *requestId;
@property (nonatomic, copy, readwrite) NSString *customerId;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, strong, readwrite) AWXPaymentMethod *paymentMethod;
@property (nonatomic, copy, readwrite) NSString *nextTriggeredBy;
@property (nonatomic, copy, readwrite) NSString *merchantTriggerReason;

@property (nonatomic, assign ,readwrite) BOOL requiresCvc;

@property (nonatomic, copy, readwrite) NSString *createdAt;
@property (nonatomic, copy, readwrite) NSString *updatedAt;
@property (nonatomic, copy, readwrite) NSString *clientSecret;
@end

@implementation AWXPaymentConsent


+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentConsent *intent = [AWXPaymentConsent new];
    intent.Id = json[@"id"];
    intent.requestId = json[@"request_id"];
    intent.customerId = json[@"customer_id"];
    intent.status     = json[@"status"];
    intent.nextTriggeredBy = json[@"next_triggered_by"];
    intent.merchantTriggerReason = json[@"merchant_trigger_reason"];
    intent.requiresCvc = [json[@"requires_cvc"] boolValue];
    NSDictionary *paymentMethod = json[@"payment_method"];
    if (paymentMethod) {
        intent.paymentMethod = [AWXPaymentMethod decodeFromJSON:paymentMethod];
    }
    intent.createdAt = json[@"created_at"];
    intent.updatedAt = json[@"updated_at"];
    intent.clientSecret = json[@"client_secret"];
    return intent;
}

@end
