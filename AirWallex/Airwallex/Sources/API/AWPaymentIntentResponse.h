//
//  AWPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class AWConfirmPaymentNextAction;

@interface AWConfirmPaymentIntentResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly, nullable) AWConfirmPaymentNextAction *nextAction;

@end

@class AWWechatPaySDKResponse;

@interface AWConfirmPaymentNextAction : NSObject

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly, nullable) AWWechatPaySDKResponse *wechatResponse;

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

@interface AWGetPaymentIntentResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSString *requestId;
@property (nonatomic, readonly) NSNumber *amount;
@property (nonatomic, readonly) NSString *currency;
@property (nonatomic, readonly) NSString *merchantOrderId;
@property (nonatomic, readonly) NSObject *order;
@property (nonatomic, readonly) NSString *descriptor;
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) NSNumber *capturedAmount;
@property (nonatomic, readonly) NSObject *latestPaymentAttempt;
@property (nonatomic, readonly) NSString *createdAt;
@property (nonatomic, readonly) NSString *updatedAt;
@property (nonatomic, readonly) NSArray <NSString *> *availablePaymentMethodTypes;

@end

NS_ASSUME_NONNULL_END
