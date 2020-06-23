//
//  AWXPaymentintentResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWXPaymentIntentResponse.h"

@interface AWXConfirmPaymentIntentResponse ()

@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, strong, readwrite, nullable) AWXConfirmPaymentNextAction *nextAction;
@property (nonatomic, strong, readwrite, nullable) AWXPaymentAttempt *latestPaymentAttempt;

@end

@implementation AWXConfirmPaymentIntentResponse

+ (id<AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXConfirmPaymentIntentResponse *response = [[AWXConfirmPaymentIntentResponse alloc] init];
    response.status = json[@"status"];
    NSDictionary *nextAction = json[@"next_action"];
    if (nextAction && [nextAction isKindOfClass:[NSDictionary class]]) {
        response.nextAction = [AWXConfirmPaymentNextAction decodeFromJSON:nextAction];
    }
    NSDictionary *latestPaymentAttempt = json[@"latest_payment_attempt"];
    if (latestPaymentAttempt && [latestPaymentAttempt isKindOfClass:[NSDictionary class]]) {
        response.latestPaymentAttempt = [AWXPaymentAttempt decodeFromJSON:latestPaymentAttempt];
    }
    return response;
}

@end

@interface AWXConfirmPaymentNextAction ()

@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, strong, readwrite, nullable) AWXWeChatPaySDKResponse *weChatPayResponse;
@property (nonatomic, strong, readwrite, nullable) AWXRedirectResponse *redirectResponse;

@end

@implementation AWXConfirmPaymentNextAction

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXConfirmPaymentNextAction *response = [[AWXConfirmPaymentNextAction alloc] init];
    response.type = json[@"type"];
    NSDictionary *data = json[@"data"];
    if (data) {
        if ([response.type isEqualToString:@"call_sdk"]) {
            response.weChatPayResponse = [AWXWeChatPaySDKResponse decodeFromJSON:data];
        } else if ([response.type isEqualToString:@"redirect"]) {
            response.redirectResponse = [AWXRedirectResponse decodeFromJSON:data];
        }
    }
    return response;
}

@end

@interface AWXWeChatPaySDKResponse ()

@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *timeStamp;
@property (nonatomic, copy, readwrite) NSString *nonceStr;
@property (nonatomic, copy, readwrite) NSString *prepayId;
@property (nonatomic, copy, readwrite) NSString *partnerId;
@property (nonatomic, copy, readwrite) NSString *package;
@property (nonatomic, copy, readwrite) NSString *sign;

@end

@implementation AWXWeChatPaySDKResponse

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXWeChatPaySDKResponse *response = [[AWXWeChatPaySDKResponse alloc] init];
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

@interface AWXRedirectResponse ()

@property (nonatomic, copy, readwrite) NSString *jwt;
@property (nonatomic, copy, readwrite) NSString *stage;
@property (nonatomic, copy, readwrite, nullable) NSString *acs;
@property (nonatomic, copy, readwrite, nullable) NSString *xid;
@property (nonatomic, copy, readwrite, nullable) NSString *req;

@end

@implementation AWXRedirectResponse

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXRedirectResponse *response = [[AWXRedirectResponse alloc] init];
    response.jwt = json[@"jwt"];
    response.stage = json[@"stage"];
    response.acs = json[@"acs"];
    response.xid = json[@"xid"];
    response.req = json[@"req"];
    return response;
}

@end

@interface AWXPaymentAttempt ()

@property (nonatomic, copy, readwrite) NSString *Id;
@property (nonatomic, copy, readwrite) NSNumber *amount;
@property (nonatomic, strong, readwrite) AWXPaymentMethod *paymentMethod;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSNumber *capturedAmount;
@property (nonatomic, copy, readwrite) NSNumber *refundedAmount;
@property (nonatomic, strong, readwrite) AWXAuthenticationData *authenticationData;

@end

@implementation AWXPaymentAttempt

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXPaymentAttempt *response = [[AWXPaymentAttempt alloc] init];
    response.Id = json[@"id"];
    response.amount = json[@"amount"];
    NSDictionary *paymentMethod = json[@"payment_method"];
    if (paymentMethod) {
        response.paymentMethod = [AWXPaymentMethod decodeFromJSON:paymentMethod];
    }
    response.status = json[@"status"];
    response.capturedAmount = json[@"captured_amount"];
    response.refundedAmount = json[@"refunded_amount"];
    NSDictionary *authenticationData = json[@"authentication_data"];
    if (authenticationData) {
        response.authenticationData = [AWXAuthenticationData decodeFromJSON:authenticationData];
    }
    return response;
}

@end

@interface AWXAuthenticationData ()

@property (nonatomic, copy, readwrite) NSString *action;
@property (nonatomic, copy, readwrite) NSString *score;
@property (nonatomic, copy, readwrite) NSString *version;

@end

@implementation AWXAuthenticationData

- (BOOL)isThreeDSVersion2
{
    if (self.version && [self.version hasPrefix:@"2."]) {
        return YES;
    }
    return NO;
}

+ (id)decodeFromJSON:(NSDictionary *)json
{
    AWXAuthenticationData *authenticationData = [[AWXAuthenticationData alloc] init];
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

@interface AWXGetPaymentIntentResponse ()

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

@implementation AWXGetPaymentIntentResponse

+ (id <AWXResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWXGetPaymentIntentResponse *response = [[AWXGetPaymentIntentResponse alloc] init];
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