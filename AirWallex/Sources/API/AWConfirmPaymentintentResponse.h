//
//  AWConfirmPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class AWConfirmPaymentNextAction;

@interface AWConfirmPaymentintentResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) AWConfirmPaymentNextAction *nextAction;

@end

@class AWWechatPaySDKResponse;

@interface AWConfirmPaymentNextAction : NSObject

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) AWWechatPaySDKResponse *wechatResponse;

+ (AWConfirmPaymentNextAction *)parse:(NSDictionary *)json;

@end

@interface AWWechatPaySDKResponse: NSObject

@property (nonatomic, readonly, nullable) NSString *appId;
@property (nonatomic, readonly) NSString *timeStamp;
@property (nonatomic, readonly) NSString *nonceStr;
@property (nonatomic, readonly) NSString *prepayId;
@property (nonatomic, readonly) NSString *partnerId;
@property (nonatomic, readonly) NSString *package;
@property (nonatomic, readonly) NSString *sign;

+ (AWWechatPaySDKResponse *)parse:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
