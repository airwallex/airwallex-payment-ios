//
//  AWXPaymentConsentResponse.m
//  Airwallex
//
//  Created by 秋风木叶下 on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentIntentResponse.h"

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

@interface AWXVerifyPaymentConsentResponse ()


@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, strong, readwrite, nullable) AWXConfirmPaymentNextAction *nextAction;

@end

@implementation AWXVerifyPaymentConsentResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXVerifyPaymentConsentResponse *response = [[AWXVerifyPaymentConsentResponse alloc] init];

    response.status = json[@"status"];
    NSDictionary *nextAction = json[@"next_action"];
    if (nextAction && [nextAction isKindOfClass:[NSDictionary class]]) {
        response.nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:nextAction];
    }

    return response;
}

@end
