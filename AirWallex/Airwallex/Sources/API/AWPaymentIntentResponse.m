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

@end

@implementation AWConfirmPaymentIntentResponse

+ (id <AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWConfirmPaymentIntentResponse *response = [[AWConfirmPaymentIntentResponse alloc] init];
    response.status = [responseObject valueForKey:@"status"];
    NSDictionary *nextAction = [responseObject valueForKey:@"next_action"];
    if (nextAction && [nextAction isKindOfClass:[NSDictionary class]]) {
        response.nextAction = [AWConfirmPaymentNextAction parse:nextAction];
    }
    return response;
}

@end

@interface AWConfirmPaymentNextAction ()

@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, strong, readwrite, nullable) AWWechatPaySDKResponse *wechatResponse;

@end

@implementation AWConfirmPaymentNextAction

+ (AWConfirmPaymentNextAction *)parse:(NSDictionary *)json
{
    AWConfirmPaymentNextAction *response = [[AWConfirmPaymentNextAction alloc] init];
    response.type = json[@"type"];
    if ([response.type isEqualToString:@"call_sdk"]) {
        response.wechatResponse = [AWWechatPaySDKResponse parse:json[@"data"]];
    }
    return response;
}

@end

@interface AWWechatPaySDKResponse ()

@property (nonatomic, copy, readwrite) NSString *appId;
@property (nonatomic, copy, readwrite) NSString *timeStamp;
@property (nonatomic, copy, readwrite) NSString *nonceStr;
@property (nonatomic, copy, readwrite) NSString *prepayId;
@property (nonatomic, copy, readwrite) NSString *partnerId;
@property (nonatomic, copy, readwrite) NSString *package;
@property (nonatomic, copy, readwrite) NSString *sign;

@end

@implementation AWWechatPaySDKResponse

+ (AWWechatPaySDKResponse *)parse:(NSDictionary *)json
{
    AWWechatPaySDKResponse *response = [[AWWechatPaySDKResponse alloc] init];
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

@interface AWGetPaymentIntentResponse ()

@property (nonatomic, copy, readwrite) NSString *Id;
@property (nonatomic, copy, readwrite) NSString *requestId;
@property (nonatomic, copy, readwrite) NSNumber *amount;
@property (nonatomic, copy, readwrite) NSString *currency;
@property (nonatomic, copy, readwrite) NSString *merchantOrderId;
@property (nonatomic, copy, readwrite) NSObject *order;
@property (nonatomic, copy, readwrite) NSString *descriptor;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSNumber *capturedAmount;
@property (nonatomic, copy, readwrite) NSObject *latestPaymentAttempt;
@property (nonatomic, copy, readwrite) NSString *createdAt;
@property (nonatomic, copy, readwrite) NSString *updatedAt;
@property (nonatomic, copy, readwrite) NSArray <NSString *> *availablePaymentMethodTypes;

@end

@implementation AWGetPaymentIntentResponse

+ (id <AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWGetPaymentIntentResponse *response = [[AWGetPaymentIntentResponse alloc] init];
    response.requestId = json[@"request_id"];
    response.amount = json[@"amount"];
    response.currency = json[@"currency"];
    response.merchantOrderId = json[@"merchant_order_id"];
    response.order = json[@"order"];
    response.descriptor = json[@"descriptor"];
    response.status = json[@"status"];
    response.capturedAmount = json[@"captured_amount"];
    response.latestPaymentAttempt = json[@"latest_payment_attempt"];
    response.createdAt = json[@"created_at"];
    response.updatedAt = json[@"updated_at"];
    response.availablePaymentMethodTypes = json[@"available_payment_method_types"];
    return response;
}

@end
