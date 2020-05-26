//
//  AWPaymentintentResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWPaymentIntentResponse.h"

@interface AWConfirmPaymentIntentResponse ()

@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, strong, readwrite, nullable) AWConfirmPaymentNextAction *nextAction;
@property (nonatomic, strong, readwrite, nullable) AWPaymentAttempt *latestPaymentAttempt;

@end

@implementation AWConfirmPaymentIntentResponse

+ (id<AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWConfirmPaymentIntentResponse *response = [[AWConfirmPaymentIntentResponse alloc] init];
    response.status = json[@"status"];
    NSDictionary *nextAction = json[@"next_action"];
    if (nextAction && [nextAction isKindOfClass:[NSDictionary class]]) {
        response.nextAction = [AWConfirmPaymentNextAction decodeFromJSON:nextAction];
    }
    NSDictionary *latestPaymentAttempt = json[@"latest_payment_attempt"];
    if (latestPaymentAttempt && [latestPaymentAttempt isKindOfClass:[NSDictionary class]]) {
        response.latestPaymentAttempt = [AWPaymentAttempt decodeFromJSON:latestPaymentAttempt];
    }
    return response;
}

@end

@interface AWConfirmPaymentNextAction ()

@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, strong, readwrite, nullable) AWWeChatPaySDKResponse *weChatPayResponse;
@property (nonatomic, strong, readwrite, nullable) AWRedirectResponse *redirectResponse;

@end

@implementation AWConfirmPaymentNextAction

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWConfirmPaymentNextAction *response = [[AWConfirmPaymentNextAction alloc] init];
    response.type = json[@"type"];
    NSDictionary *data = json[@"data"];
    if (data) {
        if ([response.type isEqualToString:@"call_sdk"]) {
            response.weChatPayResponse = [AWWeChatPaySDKResponse decodeFromJSON:data];
        } else if ([response.type isEqualToString:@"redirect"]) {
            response.redirectResponse = [AWRedirectResponse decodeFromJSON:data];
        }
    }
    return response;
}

@end

@interface AWWeChatPaySDKResponse ()

@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *timeStamp;
@property (nonatomic, copy, readwrite) NSString *nonceStr;
@property (nonatomic, copy, readwrite) NSString *prepayId;
@property (nonatomic, copy, readwrite) NSString *partnerId;
@property (nonatomic, copy, readwrite) NSString *package;
@property (nonatomic, copy, readwrite) NSString *sign;

@end

@implementation AWWeChatPaySDKResponse

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWWeChatPaySDKResponse *response = [[AWWeChatPaySDKResponse alloc] init];
    response.appId = json[@"appId"];
    response.timeStamp = json[@"timeStamp"];
    response.nonceStr = json[@"nonceStr"];
    response.prepayId = json[@"prepayId"];
    response.partnerId = json[@"partnerId"];
    response.package = json[@"package"];
    response.sign = json[@"sign"];
    return response;
}

@end

@interface AWRedirectResponse ()

@property (nonatomic, copy, readwrite) NSString *jwt;
@property (nonatomic, copy, readwrite) NSString *stage;
@property (nonatomic, copy, readwrite, nullable) NSString *acs;
@property (nonatomic, copy, readwrite, nullable) NSString *xid;
@property (nonatomic, copy, readwrite, nullable) NSString *req;

@end

@implementation AWRedirectResponse

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWRedirectResponse *response = [[AWRedirectResponse alloc] init];
    response.jwt = json[@"jwt"];
    response.stage = json[@"stage"];
    response.acs = json[@"acs"];
    response.xid = json[@"xid"];
    response.req = json[@"req"];
    return response;
}

@end

@interface AWPaymentAttempt ()

@property (nonatomic, copy, readwrite) NSString *Id;
@property (nonatomic, copy, readwrite) NSNumber *amount;
@property (nonatomic, strong, readwrite) AWPaymentMethod *paymentMethod;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSNumber *capturedAmount;
@property (nonatomic, copy, readwrite) NSNumber *refundedAmount;
@property (nonatomic, strong, readwrite) AWAuthenticationData *authenticationData;

@end

@implementation AWPaymentAttempt

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWPaymentAttempt *response = [[AWPaymentAttempt alloc] init];
    response.Id = json[@"id"];
    response.amount = json[@"amount"];
    NSDictionary *paymentMethod = json[@"payment_method"];
    if (paymentMethod) {
        response.paymentMethod = [AWPaymentMethod decodeFromJSON:paymentMethod];
    }
    response.status = json[@"status"];
    response.capturedAmount = json[@"captured_amount"];
    response.refundedAmount = json[@"refunded_amount"];
    NSDictionary *authenticationData = json[@"authentication_data"];
    if (authenticationData) {
        response.authenticationData = [AWAuthenticationData decodeFromJSON:authenticationData];
    }
    return response;
}

@end

@interface AWAuthenticationData ()

@property (nonatomic, copy, readwrite) NSString *action;
@property (nonatomic, copy, readwrite) NSString *score;
@property (nonatomic, copy, readwrite) NSString *version;

@end

@implementation AWAuthenticationData

- (BOOL)isThreeDSVersion2
{
    if (self.version && [self.version hasPrefix:@"2."]) {
        return YES;
    }
    return NO;
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWAuthenticationData *authenticationData = [[AWAuthenticationData alloc] init];
    NSDictionary *fraudData = json[@"fraud_data"];
    if (fraudData) {
        authenticationData.action = fraudData[@"action"];
        authenticationData.score = fraudData[@"score"];
    }
    NSDictionary *dsData = json[@"ds_data"];
    if (dsData) {
        authenticationData.version = dsData[@"version"];
    }
    return authenticationData;
}

@end

@interface AWGetPaymentIntentResponse ()

@property (nonatomic, copy, readwrite) NSString *Id;
@property (nonatomic, copy, readwrite) NSString *requestId;
@property (nonatomic, copy, readwrite) NSNumber *amount;
@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, copy, readwrite) NSString *merchantOrderId;
@property (nonatomic, copy, readwrite) NSDictionary *order;
@property (nonatomic, copy, readwrite) NSString *customerId;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSNumber *capturedAmount;
@property (nonatomic, copy, readwrite) NSString *createdAt;
@property (nonatomic, copy, readwrite) NSString *updatedAt;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *availablePaymentMethodTypes;
@property (nonatomic, copy, readwrite) NSString *clientSecret;

@end

@implementation AWGetPaymentIntentResponse

+ (id <AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWGetPaymentIntentResponse *response = [[AWGetPaymentIntentResponse alloc] init];
    response.Id = json[@"id"];
    response.requestId = json[@"request_id"];
    response.amount = json[@"amount"];
    response.currency = json[@"currency"];
    response.merchantOrderId = json[@"merchant_order_id"];
    response.order = json[@"order"];
    response.customerId = json[@"customer_id"];
    response.status = json[@"status"];
    response.capturedAmount = json[@"captured_amount"];
    response.createdAt = json[@"created_at"];
    response.updatedAt = json[@"updated_at"];
    response.availablePaymentMethodTypes = json[@"available_payment_method_types"];
    response.clientSecret = json[@"client_secret"];
    return response;
}

@end
