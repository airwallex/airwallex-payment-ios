//
//  AWConfirmPaymentintentResponse.m
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import "AWConfirmPaymentintentResponse.h"

@interface AWConfirmPaymentintentResponse ()

@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, strong, readwrite) AWConfirmPaymentNextAction *nextAction;

@end

@implementation AWConfirmPaymentintentResponse

+ (id <AWResponseProtocol>)parse:(NSData *)data
{
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    AWConfirmPaymentintentResponse *response = [[AWConfirmPaymentintentResponse alloc] init];
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
@property (nonatomic, strong, readwrite) AWWechatPaySDKResponse *wechatResponse;

@end

@implementation AWConfirmPaymentNextAction

+ (AWConfirmPaymentNextAction *)parse:(NSDictionary *)json
{
    AWConfirmPaymentNextAction *response = [[AWConfirmPaymentNextAction alloc] init];
    response.type = json[@"type"];
    response.wechatResponse = [AWWechatPaySDKResponse parse:json[@"data"]];
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
