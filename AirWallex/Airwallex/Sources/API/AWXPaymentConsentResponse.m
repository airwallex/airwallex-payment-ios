//
//  AWXPaymentConsentResponse.m
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentConsent.h"

@interface AWXPaymentConsentResponse ()

@property (nonatomic, strong, readwrite) AWXPaymentConsent *consent;

@end

@implementation AWXPaymentConsentResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXPaymentConsentResponse *response = [AWXPaymentConsentResponse new];
    response.consent = [AWXPaymentConsent decodeFromJSON:responseObject];
    return response;
}

@end
