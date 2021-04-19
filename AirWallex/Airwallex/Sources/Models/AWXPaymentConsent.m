//
//  AWXPaymentConsent.m
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsent.h"

@implementation AWXPaymentConsent


+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentConsent *intent = [AWXPaymentConsent new];
    intent.Id = json[@"id"];
    intent.next_triggered_by = json[@"next_triggered_by"];
    intent.merchant_trigger_reason = json[@"merchant_trigger_reason"];
    
    intent.requires_cvc = [json[@"requires_cvc"] boolValue];
    return intent;
}

@end
