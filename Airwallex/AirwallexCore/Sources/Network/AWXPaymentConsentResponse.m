//
//  AWXPaymentConsentResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2021/3/25.
//  Copyright © 2021 Airwallex. All rights reserved.
//

#import "AWXPaymentConsentResponse.h"
#import "AWXPaymentConsent.h"
#import "AWXPaymentIntentResponse.h"

@interface AWXCreatePaymentConsentResponse ()

@property (nonatomic, strong, readwrite) AWXPaymentConsent *consent;

@end

@implementation AWXCreatePaymentConsentResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXCreatePaymentConsentResponse *response = [AWXCreatePaymentConsentResponse new];
    response.consent = [AWXPaymentConsent decodeFromJSON:responseObject];
    return response;
}

@end

@interface AWXVerifyPaymentConsentResponse ()

@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSString *initialPaymentIntentId;
@property (nonatomic, strong, readwrite, nullable) AWXConfirmPaymentNextAction *nextAction;

@end

@implementation AWXVerifyPaymentConsentResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXVerifyPaymentConsentResponse *response = [[AWXVerifyPaymentConsentResponse alloc] init];

    response.status = json[@"status"];
    response.initialPaymentIntentId = json[@"initial_payment_intent_id"];
    NSDictionary *nextAction = json[@"next_action"];
    if (nextAction && [nextAction isKindOfClass:[NSDictionary class]]) {
        response.nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:nextAction];
    }

    return response;
}

@end

@interface AWXGetPaymentConsentsResponse ()

@property (nonatomic, readwrite) BOOL hasMore;
@property (nonatomic, copy, readwrite) NSArray<AWXPaymentConsent *> *items;

@end

@implementation AWXGetPaymentConsentsResponse

+ (AWXResponse *)parse:(NSData *)data {
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentConsentsResponse *response = [AWXGetPaymentConsentsResponse new];
    response.hasMore = [responseObject[@"has_more"] boolValue];
    NSMutableArray *items = [NSMutableArray array];
    NSArray *list = responseObject[@"items"];
    if (list && [list isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in list) {
            [items addObject:[AWXPaymentConsent decodeFromJSON:item]];
        }
    }
    response.items = items;
    return response;
}

@end
