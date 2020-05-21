//
//  AWPaymentintentResponse.h
//  Airwallex
//
//  Created by Victor Zhu on 2020/1/16.
//  Copyright © 2020 Airwallex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWCodable.h"
#import "AWPaymentMethod.h"
#import "AWResponseProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class AWConfirmPaymentNextAction, AWPaymentAttempt;

@interface AWConfirmPaymentIntentResponse : NSObject <AWResponseProtocol>

@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly, nullable) AWConfirmPaymentNextAction *nextAction;
@property (nonatomic, readonly, nullable) AWPaymentAttempt *latestPaymentAttempt;

@end

@class AWWeChatPaySDKResponse, AWRedirectResponse;

@interface AWConfirmPaymentNextAction : NSObject <AWJSONDecodable>

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly, nullable) AWWeChatPaySDKResponse *weChatPayResponse;
@property (nonatomic, readonly, nullable) AWRedirectResponse *redirectResponse;

@end

@interface AWWeChatPaySDKResponse: NSObject <AWJSONDecodable>

@property (nonatomic, readonly, nullable) NSString *appId;
@property (nonatomic, readonly) NSString *timeStamp;
@property (nonatomic, readonly) NSString *nonceStr;
@property (nonatomic, readonly) NSString *prepayId;
@property (nonatomic, readonly) NSString *partnerId;
@property (nonatomic, readonly) NSString *package;
@property (nonatomic, readonly) NSString *sign;

@end

@interface AWRedirectResponse : NSObject <AWJSONDecodable>

@property (nonatomic, readonly) NSString *jwt;
@property (nonatomic, readonly) NSString *stage;
@property (nonatomic, readonly, nullable) NSString *acs;
@property (nonatomic, readonly, nullable) NSString *xid;
@property (nonatomic, readonly, nullable) NSString *req;

@end


@interface AWAuthenticationData : NSObject <AWJSONDecodable>

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) NSString *score;
@property (nonatomic, readonly) NSString *version;

- (BOOL)isThreeDSVersion2;

@end

@interface AWPaymentAttempt : NSObject <AWJSONDecodable>

@property (nonatomic, readonly) NSString *Id;
@property (nonatomic, readonly) NSNumber *amount;
@property (nonatomic, readonly) AWPaymentMethod *paymentMethod;
@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) NSNumber *capturedAmount;
@property (nonatomic, readonly) NSNumber *refundedAmount;
@property (nonatomic, readonly) AWAuthenticationData *authenticationData;

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
#warning "not finished"
@property (nonatomic, readonly) AWPaymentAttempt *latestPaymentAttempt;
@property (nonatomic, readonly) NSString *createdAt;
@property (nonatomic, readonly) NSString *updatedAt;
@property (nonatomic, readonly) NSArray <NSString *> *availablePaymentMethodTypes;

@end

NS_ASSUME_NONNULL_END
